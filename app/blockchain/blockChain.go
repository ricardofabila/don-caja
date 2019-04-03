package blockchain

import (
	"encoding/hex"

	"bitbucket.org/ricardofabila/don-caja-front/app"
	"bitbucket.org/ricardofabila/don-caja-front/app/models"
	"github.com/dgraph-io/badger"
	"github.com/revel/revel"
)

func GetLatestNthBlocks(n int) []models.Block {

	latestBlock := GetLatestBlock()
	counter := 1

	var blocks = []models.Block{
		latestBlock,
	}

	currentBlock := latestBlock

	for counter < n {
		revel.AppLog.Infof("hash: %s", hex.EncodeToString(currentBlock.BlockHead.Hash))
		revel.AppLog.Infof("previous-hash: %s", hex.EncodeToString(currentBlock.BlockHead.PreviousHash))

		if len(currentBlock.BlockHead.PreviousHash) == 0 {
			break
		}

		currentBlock = GetBlockByHash(currentBlock.BlockHead.PreviousHash)
		blocks = append(blocks, currentBlock)
		counter += 1
	}

	return blocks
}

func GetBlockByHash(hash []byte) models.Block {

	var block models.Block

	readingError := app.DB.View(func(txn *badger.Txn) error {

		item, err := txn.Get(hash)

		err = item.Value(func(val []byte) error {
			block = models.Deserialize(val)
			return nil
		})

		return err
	})

	if readingError != nil {
		revel.AppLog.Errorf("Reading block by hash  on DB error.")
		revel.AppLog.Errorf("Error: %v", readingError)
	}

	return block
}

func GetLatestBlockHash() []byte {

	var latestHash []byte

	readingError := app.DB.View(func(txn *badger.Txn) error {

		item, err := txn.Get([]byte("latestHash"))

		err = item.Value(func(val []byte) error {
			// This func with val would only be called if item.Value encounters no error.
			revel.AppLog.Infof("Latest Hash: %s.", hex.EncodeToString(val))
			latestHash = val
			return nil
		})

		return err

	})

	if readingError != nil {
		revel.AppLog.Errorf("Reading latestHash on DB error.")
		revel.AppLog.Errorf("Error: %v", readingError)
	}

	return latestHash
}

func GetLatestBlock() models.Block {

	var block models.Block

	readingError := app.DB.View(func(txn *badger.Txn) error {

		item, err := txn.Get(GetLatestBlockHash())

		err = item.Value(func(val []byte) error {
			block = models.Deserialize(val)
			return nil
		})

		return err

	})

	if readingError != nil {
		revel.AppLog.Errorf("Reading latestHash on DB error.")
		revel.AppLog.Errorf("Error: %v", readingError)
	}

	return block
}

func AddBlock(block models.Block) {

	lastHash := GetLatestBlockHash()

	block.MineBlock(lastHash)

	revel.AppLog.Infof("block's hash: %s", hex.EncodeToString(block.BlockHead.Hash))

	readingError := app.DB.Update(func(txn *badger.Txn) error {
		// Save the mined block
		err := txn.Set(block.BlockHead.Hash, block.Serialize())
		if err != nil {
			return err
		}

		// update the lastest hash
		err = txn.Set([]byte("latestHash"), block.BlockHead.Hash)
		if err != nil {
			return err
		}

		return err
	})

	if readingError != nil {
		revel.AppLog.Errorf("Writing new block on DB error.")
		revel.AppLog.Errorf("Error: %v", readingError)
	}
}
