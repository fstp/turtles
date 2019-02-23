local ip = "94.255.186.181"

local function init()
    local response = http.get(
        "http://94.255.186.181:4000/init"
    )
    if response then
        local sResponse = response.readAll()
        response.close()
        return sResponse
    else
        printError("ERROR: Failed to initialize.")
    end
end

local function fetch(id)
	local response = http.get(
		"http://94.255.186.181:4000/fetch?id="..id
	)
	if response then
		local sResponse = response.readAll()
		response.close()
		return sResponse
	else
		printError("ERROR: Failed to fetch next instruction, id="..id)
	end
end

local function post(id, result)
	if result == nil then
		result = ""
	end
	local response = http.post(
		"http://94.255.186.181:4000/result",
		"id="..id.."&".."result="..textutils.urlEncode(result)
	)
	if response then
		local sResponse = response.readAll()
		response.close()
	else
		printError("ERROR: Failed to post results, id="..id.." result="..result)
	end
end

local id = init()
print("Started Turtle: "..id)

while true do
  local text = fetch(id)
  if text == ":retry" then
    print("Server issues, retrying "..id.."...")
    sleep(10)
  else
    local code = loadstring(text)
    local result = code()
    post(id, result)
  end
end