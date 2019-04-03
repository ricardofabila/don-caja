package controllers

import (
	"bitbucket.org/ricardofabila/don-caja-front/app/blockchain"
	"bitbucket.org/ricardofabila/don-caja-front/app/models"
	"github.com/revel/revel"
)

type UsersController struct {
	*revel.Controller
}

func (c UsersController) GetAllUsers() revel.Result {
	latestBlock := blockchain.GetLatestBlock()

	return c.RenderJSON(latestBlock.BlockBody.CurrentState)
}

func (c UsersController) CreateUser() revel.Result {

	var user models.User

	// if there is an error while decoding the json request
	if error := c.Params.BindJSON(&user); error != nil {
		c.Response.Status = 422
		return c.RenderJSON(map[string]string{"error": "Error creando usuario"})
	}

	if user.Name == "" {
		c.Response.Status = 422
		return c.RenderJSON(map[string]string{"error": "Error creando usuario"})
	}

	// calculate a the user's incremental id
	latestBlock := blockchain.GetLatestBlock()
	users := latestBlock.BlockBody.CurrentState

	var lastUserIndex int

	if len(users) != 0 {
		lastUserIndex = users[len(users)-1].Id + 1
	}

	user.Id = lastUserIndex

	// check the username is not taken

	for _, u := range users {
		if u.Name == user.Name {
			c.Response.Status = 422
			return c.RenderJSON(map[string]string{"error": "Error. Nombre de usuario ya existente."})
		}
	}

	// crear una transaccion con el usuario y el monto

	if user.Balance < 0 {
		c.Response.Status = 422
		return c.RenderJSON(map[string]string{"error": "Error. Balance no puede ser negativo."})
	}

	// agregar nuevo state y transacciones al block, minar y agregar a la BC
	transaction := models.Transaction{user.Id, user.Name, user.Balance}
	users = append(users, user)

	block := models.CreateBlock(users, []models.Transaction{transaction}, "rafa")
	blockchain.AddBlock(block)

	return c.RenderJSON(user)
}
