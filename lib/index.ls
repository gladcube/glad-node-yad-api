require! \./classes/Manager.ls

module.exports =
  create_manager: ({
    own_account_id
    location
    license
    api_account_id
    api_account_password
    api_version
    max_requests
  }:consts)->
    new Manager consts
