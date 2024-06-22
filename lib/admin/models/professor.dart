class Professor {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String password;

  Professor({required this.id, required this.nom, required this.prenom, required this.email, required this.password});

  factory Professor.fromJson(Map<String, dynamic> json) {
    return Professor(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      password: json['password'], // Ajout du mot de passe
    );
  }
}