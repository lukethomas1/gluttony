extends Control

signal refresh_requested

enum TIME_TAB {ALL_TIME, MONTHLY, WEEKLY, THREE_DAY, DAILY}
const COLLECTION_ID = "LeaderboardV1"

const score_entry_scene = preload("res://scenes/score_entry.tscn")

var current_tab = 0

const ONE_DAY_IN_SEC:int = 86400
const max_scores = 30


func build_query(tab:int):
	var unix_time:int = int(Time.get_unix_time_from_system())
	var greater_than_time:String = "1"

	match tab:
		TIME_TAB.ALL_TIME:
			pass
		TIME_TAB.MONTHLY:
			greater_than_time = Time.get_datetime_string_from_unix_time(unix_time - ONE_DAY_IN_SEC * 30)
		TIME_TAB.WEEKLY:
			greater_than_time = Time.get_datetime_string_from_unix_time(unix_time - ONE_DAY_IN_SEC * 7)
		TIME_TAB.THREE_DAY:
			greater_than_time = Time.get_datetime_string_from_unix_time(unix_time - ONE_DAY_IN_SEC * 3)
		TIME_TAB.DAILY:
			greater_than_time = Time.get_datetime_string_from_unix_time(unix_time - ONE_DAY_IN_SEC * 1)
		_:
			print("Unrecognized TIME_TAB value %s" % tab)

	var query = FirestoreQuery.new().from(COLLECTION_ID)
	if tab != TIME_TAB.ALL_TIME:
		query = query.where("datetime", FirestoreQuery.OPERATOR.GREATER_THAN, greater_than_time)
	query = query.order_by("score", FirestoreQuery.DIRECTION.DESCENDING).limit(max_scores)
	return query


func load_leaderboard():
	print("Loading leaderboard")
	var auth = Firebase.Auth.auth
	if !auth.is_empty():
		var query : FirestoreQuery = build_query(current_tab)
		var query_task : FirestoreTask = Firebase.Firestore.query(query)
		var result : Array = await query_task.result_query

		remove_all()

		for item in result:
			add_score(item.doc_fields["name"], item.doc_fields["score"])
	else:
		print("No auth")


func submit_score(player_name:String, score:int):
	var auth = Firebase.Auth.auth
	if !auth.is_empty():
		print("Submitting with player name %s" % player_name)
		var datetime = Time.get_datetime_string_from_system(true, false)
		var collection: FirestoreCollection = Firebase.Firestore.collection(COLLECTION_ID)

		var data = {
			"name": player_name,
			"score": score,
			"datetime": datetime,
		}
		var doc_name = "%s_%s_%s" % [data["name"].replace(" ", "-"), str(data["score"]), data["datetime"]]
		var add_task: FirestoreTask = collection.add(doc_name, data)
		var result = await add_task.add_document
		return result


func remove_all():
	for i in range(%ScoresContainer.get_child_count()):
		%ScoresContainer.get_child(i).queue_free()


func add_score(player_name: String, score: int):
	var score_entry = score_entry_scene.instantiate()
	score_entry.get_node("NameLabel").set("theme_override_font_sizes/font_size", 32)
	score_entry.get_node("ScoreLabel").set("theme_override_font_sizes/font_size", 32)
	score_entry.get_node("NameLabel").text = player_name
	score_entry.get_node("ScoreLabel").text = str(score)
	%ScoresContainer.add_child(score_entry)


func _on_texture_button_pressed():
	refresh_requested.emit()


func _on_tab_bar_tab_changed(tab:int):
	current_tab = tab
	load_leaderboard()
