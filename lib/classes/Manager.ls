require! \./Service.ls

module.exports = class Manager
  ({@own_account_id, @location, @license, @api_account_id, @api_account_password, @api_version})->
  get_collocation: (cb)->
    if @collocation? => cb null, that; return
    location_service = new Service (
      name: \LocationService
      location: @location
      license: @license
      api_account_id: @api_account_id
      api_account_password: @api_account_password
      api_version: @api_version
    )
    err, res <~ location_service.get account-id: @own_account_id
    @collocation = res.rval.value
    cb err, @collocation
  get_service: (name, cb)->
    err, collocation <~ @get_collocation
    new Service (
      name: name
      collocation: collocation
      location: @location
      license: @license
      api_account_id: @api_account_id
      api_account_password: @api_account_password
      api_version: @api_version
    ) |> -> cb null, it


