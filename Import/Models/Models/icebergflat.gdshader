shader_type spatial;

// Déclare un Uniform pour la couleur. 
// Le 'hint_color' permet de le modifier facilement dans l'inspecteur Godot.
// Le nom 'albedo_color' est conventionnel.
uniform vec4 albedo_color : hint_color; 

void vertex() {
    // Appelé pour chaque sommet. (Non modifié pour la couleur)
}

void fragment() {
    // Définit la couleur de base (Albedo) de l'iceberg en utilisant l'Uniform.
    ALBEDO = albedo_color.rgb;
    // Optionnel : Si vous souhaitez conserver une certaine brillance ou opacité
    // ALPHA = albedo_color.a; 
}

//void light() {
//    // ...
//}