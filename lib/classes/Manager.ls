require! <[wait]>
require! \./Service.ls
{wait} = wait

module.exports = class Manager
  ({@location, @license, @api_account_id, @api_account_password, @api_version, @max_requests})->
    @ <<<
      current_requests: 0
  collocations: {}
  start_request: (cb)->
    if @current_requests >= @max_requests
      <~ wait 500
      @start_request cb
    else
      @current_requests += 1
      cb!
      <~ wait 1000
      @current_requests -= 1
  get_collocation: (account_id, cb)->
    if @collocations.(account_id)? => cb null, that; return
    location_service = new Service (
      name: \LocationService
      location: @location
      license: @license
      api_account_id: @api_account_id
      api_account_password: @api_account_password
      api_version: @api_version
      manager: @
    )
    err, res <~ location_service.get account-id: account_id
    @collocations.(account_id) = res.rval.value
    cb err, @collocations.(account_id)
  get_service: (name, account_id, cb)->
    err, collocation <~ @get_collocation account_id
    new Service (
      name: name
      collocation: collocation
      location: @location
      license: @license
      api_account_id: @api_account_id
      api_account_password: @api_account_password
      api_version: @api_version
      manager: @
    ) |> -> cb null, it


