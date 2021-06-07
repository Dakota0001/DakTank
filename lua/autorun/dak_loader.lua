
-- Files are loaded in ALPHABETICAL ORDER, keep this in mind for race conditions
-- Files are loaded in the realm specified by filename prefix (eg. sv_, cl_, sh_)
-- Otherwise, files are loaded in the realm last specified by a directory name (eg. shared, server, client). Persists through sub-directories.
MsgN("\n===========[ Loading DakTank ]============\n|")

if not DTTE then DTTE = {} end

if SERVER then
	local Realms = {client = "client", server = "server", shared = "shared"}
	local Text   = "| > Loaded %s serverside file(s).\n| > Loaded %s shared file(s).\n| > Loaded %s clientside file(s)."
	local ServerCount, SharedCount, ClientCount = 0, 0, 0

	local function Load(Path, Realm)
		local Files, Directories = file.Find(Path .. "/*", "LUA")

		for _, File in ipairs(Files) do -- Load the files in the current directory
			local Sub = string.sub(File, 1, 3)

			File = Path .. "/" .. File

			-- Realm specified by filename
			if Sub == "cl_" then
				AddCSLuaFile(File)

				ClientCount = ClientCount + 1
			elseif Sub == "sv_" then
				include(File)

				ServerCount = ServerCount + 1
			elseif Sub == "sh_" then -- Shared
				include(File)
				AddCSLuaFile(File)

				SharedCount = SharedCount + 1
			elseif Realm then -- Realm specified by folder structure
				if Realm == "client" then
					AddCSLuaFile(File)

					ClientCount = ClientCount + 1
				elseif Realm == "server" then
					include(File)

					ServerCount = ServerCount + 1
				else -- Shared
					include(File)
					AddCSLuaFile(File)

					SharedCount = SharedCount + 1
				end
			end
		end

		for _, Directory in ipairs(Directories) do -- Load subsequent directories
			local Sub = string.sub(Directory, 1, 6)

			Realm = Realms[Sub] or Realm or nil

			Load(Path .. "/" .. Directory, Realm)
		end
	end

	Load("dtte")

	MsgN(Text:format(ServerCount, SharedCount, ClientCount))

elseif CLIENT then
	local Text      = "| > Loaded %s clientside file(s)."
	local FileCount = 0

	local function Load(Path)
		local Files, Directories = file.Find(Path .. "/*", "LUA")

		for _, File in ipairs(Files) do
			File = Path .. "/" .. File

			include(File)

			FileCount = FileCount + 1
		end

		for _, Directory in ipairs(Directories) do
			Load(Path .. "/" .. Directory)
		end
	end

	Load("dtte")

	if FileCount == 0 then
		MsgN("No files to load.")
	else
		MsgN(Text:format(FileCount, SkipCount))
	end
end

Load = nil
MsgN("|\n=======[ Finished Loading DakTank ]=======\n")