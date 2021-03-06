extends CanvasLayer

onready var shop_menu = $ShopMenu


func _ready():
	shop_menu.connect('closed', self, 'remove_child', [shop_menu])
	remove_child(shop_menu)
	
	
func initialize(player):
	$PlayerGUI.initialize(player.get_health_node(), player.get_purse())
#	$PauseMenu.initialize(player) TODO: Implement pause menu script


func _on_LevelLoader_loaded(level):
	var tree = get_tree()
	for seller in tree.get_nodes_in_group('seller'):
		seller.connect('shop_open_requested', self, 'shop_open')
		
	var monsters = tree.get_nodes_in_group('monster') # TODO make sure monsters are added
	var spawners = tree.get_nodes_in_group('monster_spawner') # TODO make sure spawners are added to group
	
	$LifebarBuilder.initialize(monsters, spawners)
	
	
func shop_open(seller_shop, buyer):
	add_child(shop_menu)
	shop_menu.open(seller_shop, buyer)