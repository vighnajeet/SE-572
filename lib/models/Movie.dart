/// Model to hold movie details
class Movie {

  final String id;
  final String name;
  num rating;

  Movie(this.id, this.name, this.rating);

  Movie.fromJson(Map<String, dynamic> json)
    : id = json['_id'],
      name = json['name'],
      rating = json['rating'];

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'name': name,
        'rating': rating
      };

  @override
  String toString() {
    return 'Movie{id: $id, name: $name, rating: $rating}';
  }
}