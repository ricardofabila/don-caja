package models

// TO BE ABLE TO BIND JSON TO STRUCTS, THE FIEDS MUST BE PUBLIC (UPPERCASE) OR THEY WILL BE SKIPED
type User struct {
	Id      int    `json:"id"`
	Name    string `json:"name"`
	Balance int64  `json:"balance"`
}

// TO BE ABLE TO BIND JSON TO STRUCTS, THE FIEDS MUST BE PUBLIC (UPPERCASE) OR THEY WILL BE SKIPED
type GoogleUser struct {
	Email    string `json:"email"`
	Verified bool `json:"email_verified"`
	Domain   string `json:"hd"`
}
