function CreateMainMenuOptions(_globalVars as object) as object
    obj = {
'		public
		type		: "mainMenuOptions"
'		private fields
'		functions
		Update	: MainMenuOptionsUpdate
    }
	return obj
end function

function MainMenuOptionsUpdate(_deltatime=0 as float) as void
    m.scale.x = 0.5
    m.OriginalUpdate(_deltatime)
end function