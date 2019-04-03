package app

import (
	"encoding/hex"

	"bitbucket.org/ricardofabila/don-caja-front/app/models"
	"github.com/dgraph-io/badger"
	"github.com/revel/revel"
)

var (
	// AppVersion revel app version (ldflags)
	AppVersion string

	// BuildTime revel app build-time (ldflags)
	BuildTime string

	// reference to de BadgerDb database
	DB *badger.DB
)

const (
	dbPath = "./database/blocks"
)

func InitDB() {

	opts := badger.DefaultOptions
	opts.Dir = dbPath
	opts.ValueDir = dbPath
	var err error
	DB, err = badger.Open(opts)

	if err != nil {
		revel.AppLog.Error("DB Error", err)
	}

	// this closes the conection and sets the pointer to nil
	// defer DB.Close()

	readingError := DB.Update(func(txn *badger.Txn) error {

		if _, err := txn.Get([]byte("latestHash")); err == badger.ErrKeyNotFound {
			revel.AppLog.Info("No existing blockchain found")

			users := []models.User{
				models.User{
					1,
					"ricardo",
					0},
				models.User{
					2,
					"luisito",
					0},
				models.User{
					3,
					"hidalgo sensei",
					0},
				models.User{
					4,
					"daniela",
					0},
				models.User{
					5,
					"carlangaslangas",
					0},
			}

			// Create the genesis block
			genesis := models.CreateBlock(users, []models.Transaction{}, "GENESIS")
			genesis.MineBlock(nil)

			//register the genesis block hash on DB
			err = txn.Set(genesis.BlockHead.Hash, genesis.Serialize())
			if err != nil {
				revel.AppLog.Errorf("Setting Hash to its block: %s", hex.EncodeToString(genesis.BlockHead.Hash))
				revel.AppLog.Errorf("Error: %v", err)
			}

			// update the key to the latest hash accodingly
			err = txn.Set([]byte("latestHash"), genesis.BlockHead.Hash)
			if err != nil {
				revel.AppLog.Errorf("Setting latesHash on DB error.")
				revel.AppLog.Errorf("Error: %v", err)
			}

			return err
		}

		return err
	})

	if readingError != nil {
		revel.AppLog.Errorf("Reading latestHash on DB error.")
		revel.AppLog.Errorf("Error: %v", err)
	}

}

func init() {
	// Filters is the default set of global filters.
	revel.Filters = []revel.Filter{
		revel.PanicFilter,             // Recover from panics and display an error page instead.
		revel.RouterFilter,            // Use the routing table to select the right Action
		revel.FilterConfiguringFilter, // A hook for adding or removing per-Action filters.
		revel.ParamsFilter,            // Parse parameters into Controller.Params.
		revel.SessionFilter,           // Restore and write the session cookie.
		revel.FlashFilter,             // Restore and write the flash cookie.
		revel.ValidationFilter,        // Restore kept validation errors and save new ones from cookie.
		revel.I18nFilter,              // Resolve the requested language
		HeaderFilter,                  // Add some security based headers
		revel.InterceptorFilter,       // Run interceptors around the action.
		revel.CompressFilter,          // Compress the result.
		revel.BeforeAfterFilter,       // Call the before and after filter functions
		revel.ActionInvoker,           // Invoke the action.
	}

	// Register startup functions with OnAppStart
	// revel.DevMode and revel.RunMode only work inside of OnAppStart. See Example Startup Script
	// ( order dependent )
	// revel.OnAppStart(ExampleStartupScript)
	revel.OnAppStart(InitDB)
	// revel.OnAppStart(FillCache)
}

// HeaderFilter adds common security headers
// There is a full implementation of a CSRF filter in
// https://github.com/revel/modules/tree/master/csrf
var HeaderFilter = func(c *revel.Controller, fc []revel.Filter) {
	c.Response.Out.Header().Add("X-Frame-Options", "SAMEORIGIN")
	c.Response.Out.Header().Add("X-XSS-Protection", "1; mode=block")
	c.Response.Out.Header().Add("X-Content-Type-Options", "nosniff")
	c.Response.Out.Header().Add("Referrer-Policy", "strict-origin-when-cross-origin")

	fc[0](c, fc[1:]) // Execute the next filter stage.
}

//func ExampleStartupScript() {
//	// revel.DevMod and revel.RunMode work here
//	// Use this script to check for dev mode and set dev/prod startup scripts here!
//	if revel.DevMode == true {
//		// Dev mode
//	}
//}
