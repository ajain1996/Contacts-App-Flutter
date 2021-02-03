import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CollectionReference _contactsRef =
      FirebaseFirestore.instance.collection("Contacts");

  final CollectionReference _usersRef =
      FirebaseFirestore.instance.collection("Users");

  final User _user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
          Container(
            child: Row(
              children: [
                Container(
                    margin: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.shopping_cart,
                          color: Colors.white,
                          size: 26,
                        ),
                        StreamBuilder(
                            stream: _contactsRef
                                .doc(_user.uid)
                                .collection("Cart")
                                .snapshots(),
                            builder: (context, snapshot) {
                              int _totalItems = 0;

                              if (snapshot.connectionState ==
                                  ConnectionState.active) {
                                List _documents = snapshot.data.docs;
                                _totalItems = _documents.length;
                              }
                              return Container(
                                width: 20.0,
                                height: 20.0,
                                margin: EdgeInsets.only(bottom: 20.0),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: Theme.of(context).accentColor,
                                    borderRadius: BorderRadius.circular(40)),
                                child: Text(
                                  '$_totalItems' ?? '0',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            }),
                      ],
                    )),
              ],
            ),
          ),
        ],
      ),
      body: Container(
          decoration: BoxDecoration(color: Colors.white),
          child: Stack(
            children: [
              FutureBuilder<QuerySnapshot>(
                future: _firebaseServices.usersRef
                    .doc(_firebaseServices.getUserId())
                    .collection("Cart")
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Scaffold(
                      body: Center(
                        child: Text('Error: ${snapshot.error}'),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.done) {
                    // display data in listvie
                    return ListView(
                      padding: EdgeInsets.only(bottom: 30.0),
                      children: snapshot.data.docs.map((document) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductPage(
                                  productId: document.id,
                                ),
                              ),
                            );
                          },
                          child: FutureBuilder(
                              future: _firebaseServices.productsRef
                                  .doc(document.id)
                                  .get(),
                              builder: (context, productSnap) {
                                if (productSnap.hasError) {
                                  return Container(
                                    child: Center(
                                      child: Text('${productSnap.error}'),
                                    ),
                                  );
                                }

                                if (productSnap.connectionState ==
                                    ConnectionState.done) {
                                  Map _productMap = productSnap.data.data();

                                  return Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.blueGrey,
                                          width: 1.0,
                                        ),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10.0,
                                        horizontal: 16.0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 90,
                                            height: 90,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: Image.network(
                                                "${_productMap['images'][0]}",
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(
                                              left: 16.0,
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${_productMap['name']}",
                                                  style: TextStyle(
                                                      fontSize: 18.0,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    vertical: 4.0,
                                                  ),
                                                  child: Text(
                                                    "\$${_productMap['price']}",
                                                    style: TextStyle(
                                                        fontSize: 16.0,
                                                        color: Theme.of(context)
                                                            .accentColor,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                ),
                                                Text(
                                                  "Size - ${document.data()['size']}",
                                                  style: TextStyle(
                                                      fontSize: 16.0,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                return Container(
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }),
                        );
                      }).toList(),
                    );
                  }

                  return Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
              ),
            ],
          )),
    );
  }
}
