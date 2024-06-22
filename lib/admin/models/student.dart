class Student {
final int? id;  final String nom;
  final String prenom;
  final String email;
  final String password;
  final String niveau; // Nouveau champ pour représenter le niveau de l'étudiant

  Student({
       this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.niveau, 
    required this.password, // Ajout du champ niveau au constructeur
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      password: json['password'],

      niveau: json['niveau'], // Lecture du champ niveau à partir du JSON
    );
  }

  toJson() {}
}
