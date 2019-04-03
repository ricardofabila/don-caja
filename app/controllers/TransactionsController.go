package controllers

import (
	"bitbucket.org/ricardofabila/don-caja-front/app/blockchain"
	"bitbucket.org/ricardofabila/don-caja-front/app/models"
	"github.com/revel/revel"
)

type TransactionsController struct {
	*revel.Controller
}

func (c TransactionsController) AddDeposit() revel.Result {

	var transaction models.Transaction

	// if there is an error while decoding the json request
	if error := c.Params.BindJSON(&transaction); error != nil {
		c.Response.Status = 422
		return c.RenderJSON(map[string]string{"error": "Error registrando transaccion"})
	}

	revel.AppLog.Infof("DEPOSIT TRANSACTION:  %v", transaction)

	if transaction.UserName == "" || transaction.Amount < 0 {
		c.Response.Status = 422
		return c.RenderJSON(map[string]string{"error": "Error registrando transaccion: usuario vacio o monto negativo "})
	}

	// get the blockchain's state and get the user by its id
	latestBlock := blockchain.GetLatestBlock()
	users := latestBlock.BlockBody.CurrentState

	// check the username exists via its id
	var foundUser models.User

	for i, u := range users {
		if u.Id == transaction.UserId {
			// sumar el monto al monto actual
			users[i].Balance += transaction.Amount
			foundUser = u
		}
	}

	if foundUser.Id == 0 {
		c.Response.Status = 422
		return c.RenderJSON(map[string]string{"error": "Error. Usuario no existente."})
	}

	// crear una transaccion con el usuario y el monto
	// agregar nuevo state y transacciones al block, minar y agregar a la BC
	block := models.CreateBlock(users, []models.Transaction{transaction}, "rafa")
	blockchain.AddBlock(block)

	return c.RenderJSON(transaction)

}

func (c TransactionsController) AddTransactions() revel.Result {

	var transactions []models.Transaction

	// if there is an error while decoding the json request
	if error := c.Params.BindJSON(&transactions); error != nil {
		c.Response.Status = 422
		return c.RenderJSON(map[string]string{"error": "Error registrando transacciones"})
	}

	// get the blockchain's state and get the user by its id
	latestBlock := blockchain.GetLatestBlock()
	users := latestBlock.BlockBody.CurrentState

	for _, transaction := range transactions {
		for i, user := range users {
			if user.Id == transaction.UserId {
				// sumar el monto al monto actual
				users[i].Balance += transaction.Amount
			}
		}
	}

	// crear una transaccion con el usuario y el monto
	// agregar nuevo state y transacciones al block, minar y agregar a la BC
	block := models.CreateBlock(users, transactions, "rafa")
	blockchain.AddBlock(block)

	return c.RenderJSON(transactions)
}
