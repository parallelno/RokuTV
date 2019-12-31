function CreateMainMenuOptions(_globalVars as object) as object
	obj = {
'		public
		type		: "mainMenuOptions"
'		private fields
		level		: invalid
		currentOption	: 0
		optionCount		: 3
		frameScaleSmoothness : 22.0

		tileScale1 : invalid
		tileScale2 : invalid
		tileScale3 : invalid

		STATUS_RUN		: 0
		STATUS_GAME		: 1
		STATUS_SCORE	: 2
		STATUS_ADSFREE	: 3
'		functions
		Update	: MainMenuOptionsUpdate
		Init	: MainMenuOptionsInit
		ControlListener	: MainMenuOptionsControlListener
	}
	return obj
end function

function MainMenuOptionsUpdate(_deltatime=0 as float) as void
	optionScale1 = 0
	optionScale2 = 0
	optionScale3 = 0
	if (m.currentOption = 0)
		optionScale1 = 1
	end if
	if (m.currentOption = 1)
		optionScale2 = 1
	end if
	if (m.currentOption = 2)
		optionScale3 = 1
	end if
	
	m.tileScale1.x += (optionScale1 - m.tileScale1.x) * m.frameScaleSmoothness * _deltatime
	m.tileScale2.x += (optionScale2 - m.tileScale2.x) * m.frameScaleSmoothness * _deltatime
	m.tileScale3.x += (optionScale3 - m.tileScale3.x) * m.frameScaleSmoothness * _deltatime

	m.OriginalUpdate(_deltatime)
end function

function MainMenuOptionsInit(_level as object) as void
	m.level = _level
	m.tileScale1 = m.tiles[0].scale
	m.tileScale2 = m.tiles[1].scale
	m.tileScale3 = m.tiles[2].scale
	m.level.ControlListenerSet(m)
end function

function MainMenuOptionsControlListener(_key as integer, _codes as object) as void
	if (m.active = false) return
	
	if m.level.status = m.level.STATUS_RUN
		if (_key = _codes.BUTTON_UP_PRESSED)
			m.currentOption--
		endif
		if (_key = _codes.BUTTON_DOWN_PRESSED)
			m.currentOption++ 
		endif
		if _key = _codes.BUTTON_SELECT_PRESSED
			if (m.currentOption = 0) m.level.status = m.STATUS_GAME
			if (m.currentOption = 1) m.level.status = m.STATUS_SCORE
			if (m.currentOption = 2) m.level.status = m.STATUS_ADSFREE
		endif
	endif

	m.currentOption = ClampI(m.currentOption, 0, m.optionCount-1)
end function