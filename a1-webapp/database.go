package main

import (
	firebase "firebase.google.com/go"
	"context"
	//"net/http"
	//"fmt"
	//"google.golang.org/appengine"
	"google.golang.org/api/option"
	"cloud.google.com/go/firestore"
)


func createFirestoreClient(ctx context.Context) *firestore.Client {
	serviceAccount := option.WithCredentialsFile("service_account.json")
	app, err := firebase.NewApp(ctx, nil, serviceAccount)
	if err != nil {
		panic(err)
	}
	client, err := app.Firestore(ctx)
	if err != nil {
		panic(err)
	}
	// defer client.Close()
	return client
}

//func firestoreTest(w http.ResponseWriter, r *http.Request) {
//	ctx := appengine.NewContext(r)
//	client := createFirestoreClient(ctx)
//	defer client.Close()
//	_, _, err := client.Collection("Tests").Add(ctx, map[string]interface{}{
//		"aString": "hey",
//		"aNumber": 20,
//	})
//	if err != nil {
//		panic(err)
//	}
//	fmt.Fprintln(w, "ok!")
//
//}
