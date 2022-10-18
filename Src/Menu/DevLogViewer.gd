extends RichTextLabel

var retryCounter = 3

func _ready():
	if Global.core_config.devlog_url.length() > 0:
		#warning-ignore:return_value_discarded
		$HTTPRequest.connect("request_completed",Callable(self,"requestLogComplete"))
		$HTTPRequest.request(Global.core_config.devlog_url)
		#print(Global.NB_PLUGIN_CONFIG.devlogUrl)

func requestLogComplete(_result, response_code, _headers, body):
	if response_code == 200:
		self.text = body.get_string_from_utf8()
	else:
		print("Connection Error: " + str(response_code))
		print(Global.core_config.devlog_url)
		if retryCounter < 0:
			$RetryDelayTimer.start()
		else:
			self.text = "OOOPS!\nFailed to load DevLog. (HTTP Response Code: "+ str(response_code) +")"

func retry():
	retryCounter -= 1
	$HTTPRequest.request(Global.core_config.devlog_url)


func _on_RetryDelayTimer_timeout():
	retry()


func _on_DevLogViewer_meta_clicked(meta):
	#warning-ignore:return_value_discarded
	OS.shell_open(meta)
