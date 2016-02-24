#!/usr/bin/env bats
load test_helper

setup() {
  dokku "$PLUGIN_COMMAND_PREFIX:create" l >&2
}

teardown() {
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" l >&2
}

@test "($PLUGIN_COMMAND_PREFIX:plugin:install) error when there are no arguments" {
  run dokku "$PLUGIN_COMMAND_PREFIX:plugin:install"
  assert_contains "${lines[*]}" "Please specify the service"
}

@test "($PLUGIN_COMMAND_PREFIX:plugin:uninstall) error when there are no arguments" {
  run dokku "$PLUGIN_COMMAND_PREFIX:plugin:uninstall"
  assert_contains "${lines[*]}" "Please specify the service"
}

@test "($PLUGIN_COMMAND_PREFIX:plugin:install) error when service does not exist" {
  run dokku "$PLUGIN_COMMAND_PREFIX:plugin:install" not_existing_service test_plugin
  assert_contains "${lines[*]}" "service not_existing_service does not exist"
}

@test "($PLUGIN_COMMAND_PREFIX:plugin:uninstall) error when service does not exist" {
  run dokku "$PLUGIN_COMMAND_PREFIX:plugin:uninstall" not_existing_service test_plugin
  assert_contains "${lines[*]}" "service not_existing_service does not exist"
}

@test "($PLUGIN_COMMAND_PREFIX:plugin:install) error when plugin name is missing" {
  run dokku "$PLUGIN_COMMAND_PREFIX:plugin:install" not_existing_service
  assert_contains "${lines[*]}" "Please specify the plugin name"
}

@test "($PLUGIN_COMMAND_PREFIX:plugin:uninstall) error when plugin name is missing" {
  run dokku "$PLUGIN_COMMAND_PREFIX:plugin:uninstall" not_existing_service
  assert_contains "${lines[*]}" "Please specify the plugin name"
}

@test "($PLUGIN_COMMAND_PREFIX:plugin:install) error when install from url but plugin name is missing" {
  run dokku "$PLUGIN_COMMAND_PREFIX:plugin:install" l http://dokku.me
  assert_contains "${lines[*]}" "Please specify both URL and the name of the plugin"
}

@test "($PLUGIN_COMMAND_PREFIX:plugin:install) success" {
  run dokku "$PLUGIN_COMMAND_PREFIX:plugin:install" l test_plugin
  assert_contains "${lines[*]}" "Installing test_plugin..."
}

@test "($PLUGIN_COMMAND_PREFIX:plugin:install) success with url" {
  run dokku "$PLUGIN_COMMAND_PREFIX:plugin:install" l http://dokku.me test_plugin
  assert_contains "${lines[*]}" "Installing plugin repo"
}

@test "($PLUGIN_COMMAND_PREFIX:restart) success" {
  run dokku "$PLUGIN_COMMAND_PREFIX:restart" l
  assert_success
}

