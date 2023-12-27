class_name EOSCredentials_
extends Node

# Put your Epic Games Product details here

@onready var PRODUCT_NAME = Env.get_var("PRODUCT_NAME")
@onready var PRODUCT_VERSION = Env.get_var("PRODUCT_VERSION")

@onready var PRODUCT_ID = Env.get_var("PRODUCT_ID")
@onready var SANDBOX_ID = Env.get_var("SANDBOX_ID")
@onready var DEPLOYMENT_ID = Env.get_var("DEPLOYMENT_ID")

@onready var CLIENT_ID = Env.get_var("CLIENT_ID")
@onready var CLIENT_SECRET = Env.get_var("CLIENT_SECRET")

# Random string of 64 characters
@onready var ENCRYPTION_KEY = Env.get_var("ENCRYPTION_KEY")
