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
:: This is version 0.1. Last bigger modification was on 2014-03-26
:: 2014-03-26: build the script
::
----------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------
--
--  Script Name: Arch And Design Manager
--
--  Author:   Jonathan Baecker (jb_alvardo) www.pixelcrusher.de | blog.pixelcrusher.de
--
----------------------------------------------------------------------------------------------------------------------
*/

clearlistener()
try ( destroyDialog GlobalMaterialSetting ) catch ( )	

DynamicUIRollout = newRolloutFloater "Arch And Design Manager" 1207 340

rollout GlobalMaterialSetting "Global Material Setting" (
	
	local archMtl = #()
	local rollArray = #()
	
	--GroupBox GRP_Diffuse "Diffuse" pos:[4,0] width:184 height:35
	--	colorPicker Diff "Color:" pos:[10,15] width:60 height:15 color:(color 125 125 125)
	
	button bntApply "Apply All Changes" pos:[1070,5] width:120 height:30
	
	on GlobalMaterialSetting open do (
		for mtl in scenematerials do (
			if classof mtl == mrArchMaterial do (
				append archMtl mtl
				)
			)
		
		for a = 1 to archMtl.count do (
			UIcode = "rollout MaterialSetting_" + a as string +  " \"" + archMtl[a].name + "\"\n"
			UIcode += "("
			UIcode += "GroupBox grpDiffuse" + a as string + " \"Diffuse" + "\"pos:[4,0] width:240 height:35 \n"
			UIcode += "spinner spnLevel" + a as string + " \"Level:" + "\"pos:[40,15] width:45 range:[0.0,1.0," + archMtl[a].diff_weight as string + "]\n"
			UIcode += "spinner spnRoughness" + a as string + " \"Rough.:" + "\"pos:[130,15] width:45 range:[0.0,1.0," + archMtl[a].diff_rough as string + "]\n"
			UIcode += "colorPicker picDiff" + a as string + " \"Color:" + "\"pos:[180,15] width:60 height:15 color:" + archMtl[a].diff_color as string + "\n"
			
			UIcode += "GroupBox grpReflection" + a as string + " \"Reflection" + "\"pos:[250,0] width:380 height:35 \n"
			UIcode += "spinner spnReflectivity" + a as string + " \"Refl.:" + "\"pos:[285,15] width:45 range:[0.0,1.0," + archMtl[a].refl_weight as string + "]\n"
			UIcode += "spinner spnGlossiness" + a as string + " \"Gloss.:" + "\"pos:[365,15] width:45 range:[0.0,1.0," + archMtl[a].refl_gloss as string + "]\n"
			UIcode += "spinner spnReflSample" + a as string + " \"Sample:" + "\"pos:[450,15] width:35 type:#integer range:[0,512," + archMtl[a].refl_samples as string + "]\n"
			UIcode += "checkbox chkFast" + a as string + " \"Fast" + "\"pos:[490,15] width:40 checked:" + archMtl[a].refl_interp as string + "\n"
			UIcode += "checkbox chkHlonly" + a as string + " \"Highl." + "\"pos:[533,15] width:45 checked:" + archMtl[a].refl_hlonly as string + "\n"
			UIcode += "checkbox chkMetal" + a as string + " \"Metal" + "\"pos:[580,15] width:45 checked:" + archMtl[a].refl_metal as string + "\n"
			
			UIcode += "GroupBox grpRefraction" + a as string + " \"Refraction" + "\"pos:[635,0] width:370 height:35 \n"
			UIcode += "spinner spnTransparency" + a as string + " \"Transp.:" + "\"pos:[680,15] width:45 range:[0.0,1.0," + archMtl[a].refr_weight as string + "]\n"
			UIcode += "spinner spnTGlossiness" + a as string + " \"Gloss.:" + "\"pos:[760,15] width:45 range:[0.0,1.0," + archMtl[a].refr_gloss as string + "]\n"
			UIcode += "spinner spnTransSample" + a as string + " \"Sample:" + "\"pos:[845,15] width:35 type:#integer range:[0,512," + archMtl[a].refr_samples as string + "]\n"
			UIcode += "spinner spnTIOR" + a as string + " \"IOR:" + "\"pos:[905,15] width:45 range:[0.1,50.0," + archMtl[a].refr_ior as string + "]\n"
			UIcode += "checkbox chkTFast" + a as string + " \"Fast" + "\"pos:[960,15] width:40 checked:" + archMtl[a].refr_interp as string + "\n"
			
			UIcode += "GroupBox grpAniso" + a as string + " \"Anisotropy" + "\"pos:[1010,0] width:180 height:35 \n"
			UIcode += "spinner spnAniso" + a as string + " \"Aniso.:" + "\"pos:[1050,15] width:45 range:[0.01,100.0," + archMtl[a].anisotropy as string + "]\n"
			UIcode += "spinner spnRotation" + a as string + " \"Rotation:" + "\"pos:[1140,15] width:45 range:[0.0,1.0," + archMtl[a].anisoangle as string + "]\n"
			
			UIcode += "GroupBox grpAO" + a as string + " \"Ambient Occlusion" + "\"pos:[4,40] width:175 height:35 \n"
			UIcode += "checkbox chkAO" + a as string + " \"ON" + "\"pos:[10,55] width:40 checked:" + archMtl[a].opts_ao_on as string + "\n"
			UIcode += "spinner spnAOSample" + a as string + " \"Smp.:" + "\"pos:[75,55] width:35 type:#integer range:[0,512," + archMtl[a].opts_ao_samples as string + "]\n"
			UIcode += "spinner spnAODist" + a as string + " \"Dist.:" + "\"pos:[140,55] width:35 range:[0.0,100000.0," + archMtl[a].opts_ao_distance as string + "]\n"
			
			UIcode += "GroupBox grpRound" + a as string + " \"Round Corners" + "\"pos:[185,40] width:130 height:35 \n"
			UIcode += "checkbox chkRound" + a as string + " \"ON" + "\"pos:[190,55] width:40 checked:" + archMtl[a].opts_round_corners_on as string + "\n"
			UIcode += "spinner spnRound" + a as string + " \"Radius:" + "\"pos:[265,55] width:45 range:[0.0,100000.0," + archMtl[a].opts_round_corners_radius as string + "]\n"
			
			UIcode += "GroupBox grpAdvanced" + a as string + " \"Advanced Options" + "\"pos:[320,40] width:230 height:35 \n"
			UIcode += "radioButtons radGlass" + a as string + " \"" + "\"pos:[325,55] width:40 labels:#(\"Solid\",\"Thin\")" + "\n"
			
			
			UIcode += ")"
			UIcode += "addRollout MaterialSetting_" + a as string + " DynamicUIRollout"

			execute UIcode
			
			)
		
		for b = 1 to DynamicUIRollout.rollouts.count do (
			if b > 1 do (
				append rollArray DynamicUIRollout.rollouts[b]
				)
			)
		)
		
	on bntApply pressed do (
		for c = 1 to rollArray.count do (
			archMtl[c].diff_weight = rollArray[c].controls[2].value
			archMtl[c].diff_rough = rollArray[c].controls[3].value
			archMtl[c].diff_color = rollArray[c].controls[4].color
			
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
			
			archMtl[c].anisotropy = rollArray[c].controls[19].value
			archMtl[c].anisoangle = rollArray[c].controls[20].value
			)
		
		)
		
	
	
	
	
	
	
	
	) --rollout end

addRollout GlobalMaterialSetting DynamicUIRollout rolledUp:false