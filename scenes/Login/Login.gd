extends Control


func _ready() -> void:
	# Initialize the SDK
	var init_opts = EOS.Platform.InitializeOptions.new()
	init_opts.product_name = EOSCredentials.PRODUCT_NAME
	init_opts.product_version = EOSCredentials.PRODUCT_VERSION

	var init_result := EOS.Platform.PlatformInterface.initialize(init_opts)
	if not EOS.is_success(init_result):
		print("Failed to initialize EOS SDK: ", EOS.result_str(init_result))
		return
	else:
		print("Initialized EOS SDK")

	# Create EOS platform
	var create_opts = EOS.Platform.CreateOptions.new()
	create_opts.product_id = EOSCredentials.PRODUCT_ID
	create_opts.sandbox_id = EOSCredentials.SANDBOX_ID
	create_opts.deployment_id = EOSCredentials.DEPLOYMENT_ID
	create_opts.client_id = EOSCredentials.CLIENT_ID
	create_opts.client_secret = EOSCredentials.CLIENT_SECRET
	create_opts.encryption_key = EOSCredentials.ENCRYPTION_KEY

	# Enable Social Overlay on Windows
	if OS.get_name() == "Windows":
		create_opts.flags = EOS.Platform.PlatformFlags.WindowsEnableOverlayOpengl

	var create_success := EOS.Platform.PlatformInterface.create(create_opts)
	if not create_success:
		print("Failed to create EOS Platform")
		return
	else:
		print("Created EOS Platform")

	print("EOS SDK v", EOS.Version.VersionInterface.get_version())

	# Setup Logs from EOS
	IEOS.logging_interface_callback.connect(_on_logging_interface_callback)
	var res := EOS.Logging.set_log_level(EOS.Logging.LogCategory.AllCategories, EOS.Logging.LogLevel.Info)
	if not EOS.is_success(res):
		print("Failed to set log level: ", EOS.result_str(res))
	else:
		print("Setup EOS logging successfully")

	_devauth_login()
	#_anonymous_login()


func _on_logging_interface_callback(msg) -> void:
	msg = EOS.Logging.LogMessage.from(msg)
	print("[SDK] %s | %s" % [msg.category, msg.message])


func _anonymous_login() -> void:
	# Login using Device ID (no user interaction/credentials required)
	print("make dir", DirAccess.make_dir_recursive_absolute("user://eosg-cache"))

	var opts = EOS.Connect.CreateDeviceIdOptions.new()
	opts.device_model = OS.get_name() + " " + OS.get_model_name()
	EOS.Connect.ConnectInterface.create_device_id(opts)
	await EOS.get_instance().connect_interface_create_device_id_callback

	var credentials = EOS.Connect.Credentials.new()
	credentials.token = null
	credentials.type = EOS.ExternalCredentialType.DeviceidAccessToken

	var login_options = EOS.Connect.LoginOptions.new()
	login_options.credentials = credentials
	var user_login_info = EOS.Connect.UserLoginInfo.new()
	user_login_info.display_name = "Anon User"
	login_options.user_login_info = user_login_info
	EOS.Connect.ConnectInterface.login(login_options)
	IEOS.connect_interface_login_callback.connect(_on_auth_interface_login_callback)


func _devauth_login():
	# Login using Dev Auth Tool
	var credentials = EOS.Auth.Credentials.new()
	credentials.type = EOS.Auth.LoginCredentialType.Developer
	credentials.id = "localhost:4545"
	credentials.token = "3ddelano"

	var login_opts = EOS.Auth.LoginOptions.new()
	login_opts.credentials = credentials
	login_opts.scope_flags = EOS.Auth.ScopeFlags.BasicProfile | EOS.Auth.ScopeFlags.FriendsList
	EOS.Auth.AuthInterface.login(login_opts)
	IEOS.auth_interface_login_callback.connect(_on_auth_interface_login_callback)


func _on_auth_interface_login_callback(data: Dictionary) -> void:
	if not data.success:
		print("Login failed")
		EOS.print_result(data)
		return

	print("Login successfull: local_user_id=", data.local_user_id)
