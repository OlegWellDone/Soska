﻿//----------------------------------------------
//            Realistic Car Controller
//
// Copyright © 2014 - 2024 BoneCracker Games
// https://www.bonecrackergames.com
// Ekrem Bugra Ozdoganlar
//
//----------------------------------------------

using UnityEngine;
using System.Collections;
using System.Collections.Generic;

/// <summary>
/// Changes wheels at runtime. It holds changable wheels as prefab in an array.
/// </summary>
[System.Serializable]
public class RCC_ChangableWheels : ScriptableObject {

    #region singleton
    private static RCC_ChangableWheels instance;
    public static RCC_ChangableWheels Instance { get { if (instance == null) instance = Resources.Load("RCC Assets/RCC_ChangableWheels") as RCC_ChangableWheels; return instance; } }
    #endregion

    [System.Serializable]
    public class ChangableWheels {

        public GameObject wheel;

    }

    public ChangableWheels[] wheels;

}


