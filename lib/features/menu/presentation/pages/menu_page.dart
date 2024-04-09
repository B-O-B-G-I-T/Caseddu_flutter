import 'package:flutter/material.dart';

class MenuPage extends StatelessWidget {
  MenuPage({super.key});

  final List posts = [
    {"Auteur": "bob", "Titre": "cherche un os", "Description": "à la recherche dans le jardin", "Image": "assets/images/cerf.jpg"},
    {"Auteur": "pilou", "Titre": "cherche un os", "Description": "à la recherche dans le jardin", "Image": "assets/images/femmephoto.jpg"},
    {"Auteur": "toustous", "Titre": "cherche un os", "Description": "à la recherche dans le jardin", "Image": "assets/images/objectif.jpg"},
    {"Auteur": "dim", "Titre": "cherche un os", "Description": "à la recherche dans le jardin", "Image": "assets/images/pont.jpeg"}
  ];
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            child: Column(children: [
              Container(
                height: 50,
                padding: const EdgeInsets.all(10),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text("cgglick"), Text("click")],
                ),
              ),
              Column(
                children: posts.map((post) {
                  return PostCard(post);
                }).toList(),
              )
            ]),
          ),
        ],
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final Map postData;

  const PostCard(this.postData, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 550,
      width: double.infinity,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(10)), boxShadow: [
        BoxShadow(
          color: Colors.grey.shade200,
          spreadRadius: 4,
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ]),
      child: Column(children: [
        Container(
          height: 350,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
            ),
            image: DecorationImage(
              image: AssetImage(
                postData['Image'],
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                  top: 5,
                  right: -15,
                  child: MaterialButton(
                    shape: const CircleBorder(),
                    onPressed: () {},
                    child: const Icon(Icons.abc),
                  ))
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
              postData['Titre'],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            Text(postData['Auteur']),
          ]),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [Text(postData['Description'])],
          ),
        )
      ]),
    );
  }
}
