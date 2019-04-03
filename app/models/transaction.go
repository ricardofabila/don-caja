package models

// TO BE ABLE TO BIND JSON TO STRUCTS, THE FIEDS MUST BE PUBLIC (UPPERCASE) OR THEY WILL BE SKIPED
type Transaction struct {
	UserId   int    `json:"user_id"`
	UserName string `json:"name"`
	Amount   int64  `json:"amount"`
}
