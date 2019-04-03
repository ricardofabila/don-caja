package controllers

import (
	"bitbucket.org/ricardofabila/don-caja-front/app/blockchain"
	"github.com/revel/revel"
	"strconv"
)

type DonCaja struct {
	*revel.Controller
}

func (c DonCaja) Caja() revel.Result {
	return c.RenderTemplate("don-caja/caja.html")
}

func (c DonCaja) ViewBlockchain() revel.Result {
	revel.AppLog.Info("view the blockchain")
	// return c.RenderJSON(blocks)

	n := c.Params.Query.Get("blocks")

	var err error
	var number int

	if number, err = strconv.Atoi(n); err == nil {
		c.RenderText("n debe der un numero")
	}

	if number <= 0 {
		number = 5 // default value
	}

	blocks := blockchain.GetLatestNthBlocks(number)

	c.ViewArgs["number"] = number
	c.ViewArgs["blocks"] = blocks

	return c.RenderTemplate("don-caja/blockchain.html")
}
