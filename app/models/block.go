package models

import (
	"bytes"
	"crypto/sha256"
	"encoding/binary"
	"encoding/gob"
	"encoding/hex"
	"fmt"
	"math"
	"strings"
	"time"
)

// TO BE ABLE TO BIND JSON TO STRUCTS, THE FIEDS MUST BE PUBLIC (UPPERCASE) OR THEY WILL BE SKIPED
type Block struct {
	BlockHead BlockHead `json:"Head"`
	BlockBody BlockBody `json:"Body"`
}

type BlockBody struct {
	CurrentState []User
	Transactions []Transaction
}

type BlockHead struct {
	Hash         []byte    `json:"hash"`
	MinedByUser  string    `json:"mined_by_user"`
	Nonce        int64     `json:"nonce"`
	PreviousHash []byte    `json:"previous_hash"`
	Timestamp    time.Time `json:"timestamp"`
}

func CreateBlock(users []User, transactions []Transaction, minedByUser string) Block {
	block := Block{BlockHead{nil, minedByUser, 0, nil, time.Now()}, BlockBody{users, transactions}}
	return block
}

// we calculate the hash based on the body of the block and the previous hash
func (block *Block) DeriveHash(previousHash []byte) []byte {
	// First join the bytes of the body and the previous hash on the head
	data := bytes.Join([][]byte{previousHash, []byte(fmt.Sprintf("%v", block.BlockBody.CurrentState)), []byte(fmt.Sprintf("%v", block.BlockBody.Transactions)), int64ToBytes(block.BlockHead.Nonce)}, []byte{})
	hash := sha256.Sum256(data)
	return hash[:]
}

func int64ToBytes(num int64) []byte {
	buffer := new(bytes.Buffer)
	err := binary.Write(buffer, binary.BigEndian, num)
	if err != nil {
		fmt.Println("binary.Write failed:", err)
	}
	return buffer.Bytes()
}

// This is the proof of wok
func (block *Block) MineBlock(previousHash []byte) {
	var nonce int64

	println("MINING BLOCK")

	block.BlockHead.PreviousHash = previousHash

	for nonce < math.MaxInt64 {
		block.BlockHead.Nonce = nonce
		hash := block.DeriveHash(previousHash)

		str := hex.EncodeToString(hash)
		//println(str)

		// more zeroes equals more dificulty
		if strings.HasPrefix(str, "0000") {
			block.BlockHead.Hash = hash
			break
		} else {
			nonce++
		}

	}

	println("BLOCK MINED :)")
}

func (b *Block) Serialize() []byte {
	var res bytes.Buffer
	encoder := gob.NewEncoder(&res)

	err := encoder.Encode(b)

	// TODO handle error
	if err != nil {
		fmt.Printf("%v", err)
	}
	return res.Bytes()
}

func Deserialize(data []byte) Block {
	var block Block

	decoder := gob.NewDecoder(bytes.NewReader(data))

	err := decoder.Decode(&block)

	// TODO handle error
	if err != nil {
		fmt.Printf("%v", err)
	}

	return block
}
