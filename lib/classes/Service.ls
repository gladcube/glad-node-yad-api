require! <[wait soap]>
{wait} = wait

module.exports = class Service
  @current_requests = 0
  @max_requests = 10
  ({@name, @collocation, @location, @license, @api_account_id, @api_account_password, @api_version})->
  url:~ -> @_url ?= "https://#{@location}/services/#{@api_version}/#{@name}?wsdl"
  endpoint:~ ->
    @_endpoint ?=
      switch @name
      | \LocationService => "https://#{@location}/services/#{@api_version}/#{@name}"
      | _ => "https://#{@collocation}/services/#{@api_version}/#{@name}"
  get_client: (cb)->
    err, client <~ soap.create-client do
      @url
      ,
        endpoint: @endpoint
        ignored-namespaces:
          namespaces: <[targetNamespace typedNamespace]>
          override: yes
    client.add-soap-header do
      (
        RequestHeader:
          license: @license
          api-account-id: @api_account_id
          api-account-password: @api_account_password
      ), "", "tns"
    cb err, client
  start_request: (cb)->
    if @@current_requests >= @@max_requests
      <~ wait 500
      @start_request cb
    else
      @@current_requests += 1
      cb!
      <~ wait 1000
      @@current_requests -= 1
  execute: (method, args, cb)->
    err, client <~ @get_client
    <~ @start_request
    client.(method) args, cb
  get: (args, cb)->
    @execute \get, args, cb
  mutate: (args, cb)->
    @execute \mutate, args, cb
  add: (body, cb)->
    @mutate (
      operations: [
        operator: \ADD
        account-id: body.account-id
        operand: (
          body
          |> obj-to-pairs
          |> reject ( .0 is \accountId)
          |> pairs-to-obj
        )
      ]
    ), cb
  remove: (body, cb)->
    @mutate (
      operations: [
        operator: \REMOVE
        account-id: body.account-id
        operand: (
          body
          |> obj-to-pairs
          |> reject ( .0 is \accountId)
          |> pairs-to-obj
        )
      ]
    ), cb


