Config = {}

--[[ Command ]]--
Config.Command = "mdt"

Config.Jobs = {"medic"}

--[[ Offices ]]--
Config.UseOffice = true
Config.Open = { 
	['key'] = 0xCEFD9220, -- E
	['text'] = "Presiona ~e~[E] ~q~ para abrir el Archivo",
	} 
Config.Office = {
    [1] = {
        coords={2733.8161, -1230.578, 50.37041}, 
    },
}

--[[ Notifys ]]--
Config.Notify = {  
	['1'] = "Los cambios han sido guardados.",
	['2'] = "Los cambios en el informe han sido guardados.",
	['3'] = "El informe ha sido eliminado correctamente.",
	['4'] = "Se ha presentado un nuevo informe.",
	['5'] = "",
	['6'] = "",
	['7'] = "No se pudo encontrar este informe.",
	['8'] = "Nota guardada.",
	['9'] = "Nota eliminada.",	
	} 
