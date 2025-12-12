## @class_doc
## @description Classe de ressource personnalisee (Resource) pour stocker les metadonnees
## d'un meuble, y compris sa scene, son nom, son stock, son compte de restockage
## et son icone d'inventaire.
## @tags data, resource, inventory, item

class_name FurnitureInfo
extends Resource

## @var_doc
## @description Reference a la scene PackedScene du meuble.
## C'est cette scene qui sera instanciee lors du placement dans le monde 3D.
## @type PackedScene
## @tags scene, data
var scene: PackedScene

## @var_doc
## @description Nom d'affichage du meuble dans l'interface utilisateur et l'inventaire.
## @type String
## @tags ui, data
var name: String

## @var_doc
## @description Nombre d'unites de cet article actuellement en stock dans l'inventaire du joueur.
## @type int
## @tags inventory, state
var stock: int

## @var_doc
## @description Nombre d'unites que le joueur recoit a chaque restockage reussi de cet article.
## @type int
## @tags inventory, config
var restock_count: int

## @var_doc
## @description Texture 2D utilisee pour representer le meuble dans l'inventaire/UI.
## @type Texture2D
## @tags ui, asset
var image: Texture2D
