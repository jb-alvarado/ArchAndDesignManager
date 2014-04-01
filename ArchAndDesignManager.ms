/*
----------------------------------------------------------------------------------------------------------------------
::
::    Description: This MaxScript is for manipulate a bunch of arch and design materials
::
----------------------------------------------------------------------------------------------------------------------
:: LICENSE ----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
::
::    Copyright (C) 2014 Jonathan Baecker (jb_alvarado)
::
::    This program is free software: you can redistribute it and/or modify
::    it under the terms of the GNU General Public License as published by
::    the Free Software Foundation, either version 3 of the License, or
::    (at your option) any later version.
::
::    This program is distributed in the hope that it will be useful,
::    but WITHOUT ANY WARRANTY; without even the implied warranty of
::    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
::    GNU General Public License for more details.
::
::    You should have received a copy of the GNU General Public License
::    along with this program.  If not, see <http://www.gnu.org/licenses/>.
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------
:: History --------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
::
:: This is version 0.75. Last bigger modification was on 2014-03-27
:: 2014-03-26: build the script
:: 2014-03-27: add most functions
:: 2014-03-28: fix sampling
:: 2014-03-30: add texture button and other fixes
:: 2014-04-01: add rightclick menu for bitmap
::
----------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------
--
--  Script Name: Arch And Design Manager
--
--  Author:   Jonathan Baecker (jb_alvardo) www.pixelcrusher.de | blog.pixelcrusher.de | www.animations-and-more.com
--
----------------------------------------------------------------------------------------------------------------------
*/

try ( destroyDialog GlobalMaterialSetting ) catch ( )	

MaterialRollout = newRolloutFloater "Arch And Design Manager" 1570 330

rollout GlobalMaterialSetting "Global Control" (
	--global variables
	local archMtl = #()
	local rollArray = #()
	local presetsArr = #()
	local matPresets = #()
	local presetVar = #()
	local PreName = #("Preset 0")
	local PreNum = 1
	
	button bntRefresh "Refresh List" pos:[3,5] width:70 height:30
	
	GroupBox GRP_Sample "Sampling Control" pos:[80,0] width:410 height:35
		spinner spnOverSample "Over:" pos:[115,15] width:40 range:[0,1000,12] type:#integer
		spinner spnUnderSample "Under:" pos:[193,15] width:40 range:[0,1000,1000] type:#integer
		spinner spnGlSample "To:" pos:[255,15] width:40 range:[0,1000,8] type:#integer
		button bntToRefl "Affect Reflection" pos:[300,15] width:90 height:16
		button bntToRefr "Affect Refraction" pos:[395,15] width:90 height:16
	
	GroupBox GRP_Effect "Effect Control" pos:[495,0] width:482 height:35
		checkbox chkAO "AO" pos:[500,15] width:35 height:16
		checkbox chkAOExact "Exact" pos:[537,15] width:45 height:16
		spinner spnAOSample "Smp.:" pos:[615,15] width:35 range:[0,1000,16] type:#integer
		spinner spnAODist "Dst.:" pos:[678,15] width:45 range:[0.0,1000000.0,4.0] type:#worldunits
		button bntAppAO "Apply AO" pos:[728,15] width:50 height:16
		checkbox chkRound "Round Co." pos:[783,15] width:70 height:16
		spinner spnRound "" pos:[852,15] width:45 range:[0.0,1000000.0,0.25] type:#worldunits
		button bntRoundC "Apply Corner" pos:[902,15] width:70 height:16
		
	GroupBox GRP_Special "Special Control" pos:[982,0] width:328 height:35	
		checkbox chkBackFace "Back Face" pos:[988,15] width:70 height:16
		checkbox chkAlpha "Trans. Alpha" pos:[1058,15] width:80 height:16
		checkbox chkSingleSample "Single Sample" pos:[1141,15] width:82 height:16
		button bntSpecials "Apply Specials" pos:[1228,15] width:77 height:16
		
	GroupBox GRP_Preset "Presets" pos:[1315,0] width:143 height:35
		dropDownList ddlPresets "" pos:[1320,12] width: 70 items:PreName
		button bntSavePreset "Set" pos:[1392,12] width:30 height:20
		button bntRunPreset "Run" pos:[1424,12] width:30 height:20
	
	button bntApply "Apply All Changes" pos:[1463,5] width:92 height:30

	-- function for fill up the preset array
	fn fillPreset mS = (
		join presetVar #( matPresets = #( mS.name, mS.diff_weight, mS.diff_color, mS.diff_color_map, \
			mS.refl_weight, mS.refl_gloss, mS.refl_samples, mS.refl_interp, mS.refl_hlonly, \
			mS.refl_metal, mS.refr_weight, mS.refr_gloss, mS.refr_samples, mS.refr_ior, \
			mS.refr_interp, mS.refl_func_fresnel, mS.opts_ao_on, mS.opts_ao_samples, \
			mS.opts_ao_exact, mS.opts_ao_distance, mS.opts_round_corners_on, \
			mS.opts_round_corners_radius, mS.opts_1sided, mS.opts_backface_cull, \
			mS.opts_propagate_alpha, mS.single_env_sample, mS.bump_map_on, mS.bump_map_amt ) )
		)
	
	-- function for search arch and design materials and build roullouts
	fn fillRollout = (
		presetVar = #()
		archTmp = #()
		
		-- get all arch and design materials
		for mtl in scenematerials do (
			if classof mtl == mrArchMaterial then (
				appendifunique archTmp mtl
				) else (
					if ( superclassof mtl == material AND getNumSubMtls mtl > 0 ) do (
						for d = 1 to getNumSubMtls mtl do (
							if ( getSubMtl mtl d ) != undefined AND classof ( getSubMtl mtl d ) == mrArchMaterial do (
								appendifunique archTmp ( getSubMtl mtl d )
								)
							)
						)
					)
			)
		
		-- count materials in arch. array and over 220 stop
		if archTmp.count > 90 do (
			if not queryBox "Warning: you have more then 90 materials in your scene. Will you continue with display only 90?" title:"Arch And Design Manager" then (
				return false
				)
			)

		-- sort the material array 
		fn compMatNames name1 name2 = stricmp name1.name name2.name
 
		archMtl = for i = 1 to archTmp.count where i <=90 collect archTmp[i]
		qSort archMtl compMatNames

		-- build material rollouts
		for a = 1 to archMtl.count do (
			ro = "rollout MaterialSetting_" + a as string +  " \"" + archMtl[a].name + "\"\n"
			ro += "(\n"
			ro += "GroupBox grpDiffuse" + a as string + " \"Diffuse\" pos:[4,0] width:151 height:35 \n"
			ro += "spinner spnLevel" + a as string + " \"Level:\" pos:[40,15] width:45 range:[0.0,1.0," + archMtl[a].diff_weight as string + "]\n"
			ro += "colorPicker picDiff" + a as string + " \"\" pos:[90,15] width:40 height:15 color:" + archMtl[a].diff_color as string + "\n"
			ro += "mapButton picMap" + a as string + " \"\" pos:[135,15] width:15 height:15 \n"

			ro += "fn createMenu" + a as string + " = (\n"
			ro += "	if picMap" + a as string + ".map != undefined do (\n"
			ro += "		rcMenu rcMap" + a as string + " (\n"
			ro += "		menuItem ClearM \"Clear\"\n"
			ro += "		on ClearM picked do ( picMap" + a as string + ".map = undefined; picMap" + a as string + ".text = \"\" )\n"
			ro += "		)\n"
			ro += "		popUpMenu rcMap" + a as string + "\n"
			ro += "		)\n"
			ro += "	)\n"
			ro += "on picMap" + a as string + " picked texmap do if picMap" + a as string + ".map != undefined do picMap" + a as string + ".text = \"M\" \n"
			ro += "on picMap" + a as string + " rightclick do createMenu" + a as string + "() \n"
			
			ro += "GroupBox grpReflection" + a as string + " \"Reflection\" pos:[160,0] width:380 height:35 \n"
			ro += "spinner spnReflectivity" + a as string + " \"Refl.:\" pos:[195,15] width:45 range:[0.0,1.0," + archMtl[a].refl_weight as string + "]\n"
			ro += "spinner spnGlossiness" + a as string + " \"Gloss.:\" pos:[275,15] width:45 range:[0.0,1.0," + archMtl[a].refl_gloss as string + "]\n"
			ro += "spinner spnReflSample" + a as string + " \"Sample:\" pos:[360,15] width:35 type:#integer range:[0,1000," + archMtl[a].refl_samples as string + "]\n"
			ro += "checkbox chkFast" + a as string + " \"Fast\" pos:[400,15] width:40 checked:" + archMtl[a].refl_interp as string + "\n"
			ro += "checkbox chkHlonly" + a as string + " \"Highl.\" pos:[443,15] width:45 checked:" + archMtl[a].refl_hlonly as string + "\n"
			ro += "checkbox chkMetal" + a as string + " \"Metal\" pos:[490,15] width:45 checked:" + archMtl[a].refl_metal as string + "\n"
			
			ro += "GroupBox grpRefraction" + a as string + " \"Refraction\" pos:[545,0] width:363 height:35 \n"
			ro += "spinner spnTransparency" + a as string + " \"Transp.:\" pos:[590,15] width:45 range:[0.0,1.0," + archMtl[a].refr_weight as string + "]\n"
			ro += "spinner spnTGlossiness" + a as string + " \"Gloss.:\" pos:[670,15] width:45 range:[0.0,1.0," + archMtl[a].refr_gloss as string + "]\n"
			ro += "spinner spnTransSample" + a as string + " \"Sample:\" pos:[755,15] width:35 type:#integer range:[0,1000," + archMtl[a].refr_samples as string + "]\n"
			ro += "spinner spnTIOR" + a as string + " \"IOR:\" pos:[815,15] width:45 range:[0.1,50.0," + archMtl[a].refr_ior as string + "]\n"
			ro += "checkbox chkTFast" + a as string + " \"Fast\" pos:[865,15] width:40 checked:" + archMtl[a].refr_interp as string + "\n"
			
			ro += "GroupBox grpBRDF" + a as string + " \"BRDF\" pos:[913,0] width:107 height:35 \n"
			ro += "radioButtons radBRDF" + a as string + " \"\" pos:[918,15] labels:#(\"IOR\",\"Custom\") default:" + ( if archMtl[a].refl_func_fresnel == on then 1 else 2 ) as string + "\n"
			
			ro += "GroupBox grpAO" + a as string + " \"Effects\" pos:[1025,0] width:282 height:35 \n"
			ro += "checkbox chkAO" + a as string + " \"AO\" pos:[1030,15] width:33 checked:" + archMtl[a].opts_ao_on as string + "\n"
			ro += "spinner spnAOSample" + a as string + " \"Smp.:\" pos:[1095,15] width:35 type:#integer range:[0,1000," + archMtl[a].opts_ao_samples as string + "]\n"
			ro += "spinner spnAODist" + a as string + " \"Dist.:\" pos:[1161,15] width:35 range:[0.0,100000.0," + archMtl[a].opts_ao_distance as string + "]\n"
			ro += "checkbox chkRound" + a as string + " \"Round C.\" pos:[1200,15] width:62 checked:" + archMtl[a].opts_round_corners_on as string + "\n"
			ro += "spinner spnRound" + a as string + " \"\" pos:[1262,15] width:40 range:[0.0,100000.0," + archMtl[a].opts_round_corners_radius as string + "]\n"
			
			ro += "GroupBox grpSpecial" + a as string + " \"Special Options\" pos:[1312,0] width:243 height:35 \n"
			ro += "radioButtons radGlass" + a as string + " \"\" pos:[1315,15] width:40 labels:#(\"Solid\",\"Thin\") default:" + ( if archMtl[a].opts_1sided == off then 1 else 2 ) as string + "\n"
			ro += "checkbox chkBackFace" + a as string + " \"BackFace\" pos:[1402,15] width:65 checked:" + archMtl[a].opts_backface_cull as string + "\n"
			ro += "checkbox chkBump" + a as string + " \"Bump\" pos:[1469,15] width:45 checked:" + archMtl[a].bump_map_on as string + "\n"
			ro += "spinner spnBump" + a as string + " \"\" pos:[1515,15] width:35 range:[0.0,10.0," + archMtl[a].bump_map_amt as string + "]\n"
			
			ro += ")\n"
			
			ro += "addRollout MaterialSetting_" + a as string + " MaterialRollout"

			execute ro as string
			
			fillPreset archMtl[a]
			)
							
		append presetsArr presetVar
			
		-- save rollouts in array
		for b = 1 to MaterialRollout.rollouts.count do (
			if b > 1 do (
				append rollArray MaterialRollout.rollouts[b]
				)
			)
			rollArray
		) --fillRollout end
	
	on GlobalMaterialSetting open do (
		fillRollout()
		for i = 1 to archMtl.count do (
			if archMtl[i].diff_color_map != undefined do (
				rollArray[i].controls[4].map = archMtl[i].diff_color_map
				rollArray[i].controls[4].text = "M"
				)
			)	
		)
		
	-- refresh the material list
	on bntRefresh pressed do (
		archMtl = #()
		for roll in rollArray do removeRollout roll
		rollArray = #()
		fillRollout()
		
		for i = 1 to archMtl.count do (
			if archMtl[i].diff_color_map != undefined do (
				rollArray[i].controls[4].map = archMtl[i].diff_color_map
				rollArray[i].controls[4].text = "M"
				)
			)
		)
		
	-- apply gobal reflection glossy sample	
	on bntToRefl pressed do (
		for mt in archMtl do (
			if (mt.refl_gloss < 1.0 AND mt.refl_samples > spnOverSample.value AND mt.refl_samples < spnUnderSample.value) do (
				mt.refl_samples = spnGlSample.value
				)
			)
		archMtl = #()
		for roll in rollArray do removeRollout roll
		rollArray = #()
		fillRollout()
		
		for i = 1 to archMtl.count do (
			if archMtl[i].diff_color_map != undefined do (
				rollArray[i].controls[4].map = archMtl[i].diff_color_map
				rollArray[i].controls[4].text = "M"
				)
			)
		)
		
	-- apply gobal refraction glossy sample	
	on bntToRefr pressed do (
		for mt in archMtl do (
			if (mt.refr_gloss < 1.0 AND mt.refr_samples > spnOverSample.value AND mt.refr_samples < spnUnderSample.value) do (
				mt.refr_samples = spnGlSample.value
				)
			)
		archMtl = #()
		for roll in rollArray do removeRollout roll
		rollArray = #()
		fillRollout()
		
		for i = 1 to archMtl.count do (
			if archMtl[i].diff_color_map != undefined do (
				rollArray[i].controls[4].map = archMtl[i].diff_color_map
				rollArray[i].controls[4].text = "M"
				)
			)
		)	
	
	-- apply gobal AO settings
	on bntAppAO pressed do (
		for mt in archMtl do (
			mt.opts_ao_on = chkAO.checked
			mt.opts_ao_exact = chkAOExact.checked
			mt.opts_ao_samples = spnAOSample.value
			mt.opts_ao_distance = spnAODist.value
			)
		archMtl = #()
		for roll in rollArray do removeRollout roll
		rollArray = #()
		fillRollout()
		
		for i = 1 to archMtl.count do (
			if archMtl[i].diff_color_map != undefined do (
				rollArray[i].controls[4].map = archMtl[i].diff_color_map
				rollArray[i].controls[4].text = "M"
				)
			)
		)
		
	-- apply gobal round corners settings	
	on bntRoundC pressed do (
		for mt in archMtl do (
			mt.opts_round_corners_on = chkRound.checked
			mt.opts_round_corners_radius = spnRound.value
			)
		archMtl = #()
		for roll in rollArray do removeRollout roll
		rollArray = #()
		fillRollout()
		
		for i = 1 to archMtl.count do (
			if archMtl[i].diff_color_map != undefined do (
				rollArray[i].controls[4].map = archMtl[i].diff_color_map
				rollArray[i].controls[4].text = "M"
				)
			)
		)
	
	-- apply gobal special effects settings	
	on bntSpecials pressed do (
		for mt in archMtl do (
			mt.opts_backface_cull = chkBackFace.checked
			mt.opts_propagate_alpha = chkAlpha.checked
			mt.single_env_sample = chkSingleSample.checked
			)
		archMtl = #()
		for roll in rollArray do removeRollout roll
		rollArray = #()
		fillRollout()
		
		for i = 1 to archMtl.count do (
			if archMtl[i].diff_color_map != undefined do (
				rollArray[i].controls[4].map = archMtl[i].diff_color_map
				rollArray[i].controls[4].text = "M"
				)
			)
		)		

	-- Set material settings as preset
	on bntSavePreset pressed do (
		for c = 1 to rollArray.count do (
			archMtl[c].diff_weight = rollArray[c].controls[2].value
			archMtl[c].diff_color = rollArray[c].controls[3].color
			archMtl[c].diff_color_map = rollArray[c].controls[4].map
			
			archMtl[c].refl_weight = rollArray[c].controls[6].value
			archMtl[c].refl_gloss = rollArray[c].controls[7].value
			archMtl[c].refl_samples = rollArray[c].controls[8].value
			archMtl[c].refl_interp = rollArray[c].controls[9].checked
			archMtl[c].refl_hlonly = rollArray[c].controls[10].checked
			archMtl[c].refl_metal = rollArray[c].controls[11].checked
			
			archMtl[c].refr_weight = rollArray[c].controls[13].value
			archMtl[c].refr_gloss = rollArray[c].controls[14].value
			archMtl[c].refr_samples = rollArray[c].controls[15].value
			archMtl[c].refr_ior = rollArray[c].controls[16].value
			archMtl[c].refr_interp = rollArray[c].controls[17].checked
			
			archMtl[c].refl_func_fresnel = if rollArray[c].controls[19].state == 1 then on else off
			
			archMtl[c].opts_ao_on = rollArray[c].controls[21].checked
			archMtl[c].opts_ao_samples = rollArray[c].controls[22].value
			archMtl[c].opts_ao_distance = rollArray[c].controls[23].value
			archMtl[c].opts_round_corners_on = rollArray[c].controls[24].checked
			archMtl[c].opts_round_corners_radius = rollArray[c].controls[25].value

			archMtl[c].opts_1sided = if rollArray[c].controls[27].state == 1 then off else on
			archMtl[c].opts_backface_cull = rollArray[c].controls[28].checked
			archMtl[c].bump_map_on = rollArray[c].controls[29].checked
			archMtl[c].bump_map_amt = rollArray[c].controls[30].value
			)
			
		archMtl = #()
		for roll in rollArray do removeRollout roll
		rollArray = #()
		fillRollout()
		
		for i = 1 to archMtl.count do (
			if archMtl[i].diff_color_map != undefined do (
				rollArray[i].controls[4].map = archMtl[i].diff_color_map
				rollArray[i].controls[4].text = "M"
				)
			)
		
		join PreName #("Preset " + PreNum as string )
		ddlPresets.items = PreName
		PreNum += 1
		ddlPresets.selection = PreNum
		)
		
	-- run material settings from preset
	on bntRunPreset pressed do (
		pS = ddlPresets.selection
		
		for m = 1 to archMtl.count do (
			if archMtl[m].name == presetsArr[pS][m][1] do (
				archMtl[m].diff_weight = presetsArr[pS][m][2]
				archMtl[m].diff_color = presetsArr[pS][m][3]
				archMtl[m].diff_color_map = presetsArr[pS][m][4]
				archMtl[m].refl_weight = presetsArr[pS][m][5]
				archMtl[m].refl_gloss = presetsArr[pS][m][6]
				archMtl[m].refl_samples = presetsArr[pS][m][7]
				archMtl[m].refl_interp = presetsArr[pS][m][8]
				archMtl[m].refl_hlonly = presetsArr[pS][m][9]
				archMtl[m].refl_metal = presetsArr[pS][m][10]
				archMtl[m].refr_weight = presetsArr[pS][m][11]
				archMtl[m].refr_gloss = presetsArr[pS][m][12]
				archMtl[m].refr_samples = presetsArr[pS][m][13]
				archMtl[m].refr_ior = presetsArr[pS][m][14]
				archMtl[m].refr_interp = presetsArr[pS][m][15]
				archMtl[m].refl_func_fresnel = presetsArr[pS][m][16]
				archMtl[m].opts_ao_on = presetsArr[pS][m][17]
				archMtl[m].opts_ao_samples = presetsArr[pS][m][18]
				archMtl[m].opts_ao_exact = presetsArr[pS][m][19]
				archMtl[m].opts_ao_distance = presetsArr[pS][m][20]
				archMtl[m].opts_round_corners_on = presetsArr[pS][m][21]
				archMtl[m].opts_round_corners_radius = presetsArr[pS][m][22]
				archMtl[m].opts_1sided = presetsArr[pS][m][23]
				archMtl[m].opts_backface_cull = presetsArr[pS][m][24]
				archMtl[m].opts_propagate_alpha = presetsArr[pS][m][25]
				archMtl[m].single_env_sample = presetsArr[pS][m][26]
				archMtl[m].bump_map_on = presetsArr[pS][m][27]
				archMtl[m].bump_map_amt = presetsArr[pS][m][28]
				)
			)
			
		archMtl = #()
		for roll in rollArray do removeRollout roll
		rollArray = #()
		fillRollout()
		
		for i = 1 to archMtl.count do (
			if archMtl[i].diff_color_map != undefined do (
				rollArray[i].controls[4].map = archMtl[i].diff_color_map
				rollArray[i].controls[4].text = "M"
				)
			)
		)
		
	on bntApply pressed do (
		-- apply change from gui in material
		for c = 1 to rollArray.count do (
			archMtl[c].diff_weight = rollArray[c].controls[2].value
			archMtl[c].diff_color = rollArray[c].controls[3].color
			archMtl[c].diff_color_map = rollArray[c].controls[4].map
			
			archMtl[c].refl_weight = rollArray[c].controls[6].value
			archMtl[c].refl_gloss = rollArray[c].controls[7].value
			archMtl[c].refl_samples = rollArray[c].controls[8].value
			archMtl[c].refl_interp = rollArray[c].controls[9].checked
			archMtl[c].refl_hlonly = rollArray[c].controls[10].checked
			archMtl[c].refl_metal = rollArray[c].controls[11].checked
			
			archMtl[c].refr_weight = rollArray[c].controls[13].value
			archMtl[c].refr_gloss = rollArray[c].controls[14].value
			archMtl[c].refr_samples = rollArray[c].controls[15].value
			archMtl[c].refr_ior = rollArray[c].controls[16].value
			archMtl[c].refr_interp = rollArray[c].controls[17].checked
			
			archMtl[c].refl_func_fresnel = if rollArray[c].controls[19].state == 1 then on else off
			
			archMtl[c].opts_ao_on = rollArray[c].controls[21].checked
			archMtl[c].opts_ao_samples = rollArray[c].controls[22].value
			archMtl[c].opts_ao_distance = rollArray[c].controls[23].value
			archMtl[c].opts_round_corners_on = rollArray[c].controls[24].checked
			archMtl[c].opts_round_corners_radius = rollArray[c].controls[25].value

			archMtl[c].opts_1sided = if rollArray[c].controls[27].state == 1 then off else on
			archMtl[c].opts_backface_cull = rollArray[c].controls[28].checked
			archMtl[c].bump_map_on = rollArray[c].controls[29].checked
			archMtl[c].bump_map_amt = rollArray[c].controls[30].value
			)
			
		archMtl = #()
		for roll in rollArray do removeRollout roll
		rollArray = #()
		fillRollout()
		
		for i = 1 to archMtl.count do (
			if archMtl[i].diff_color_map != undefined do (
				rollArray[i].controls[4].map = archMtl[i].diff_color_map
				rollArray[i].controls[4].text = "M"
				)
			)
		
		) -- bntApply end
		
	) --rollout end

addRollout GlobalMaterialSetting MaterialRollout rolledUp:false