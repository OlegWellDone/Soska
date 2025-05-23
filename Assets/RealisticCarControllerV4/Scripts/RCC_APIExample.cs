﻿//----------------------------------------------
//            Realistic Car Controller
//
// Copyright © 2014 - 2024 BoneCracker Games
// https://www.bonecrackergames.com
// Ekrem Bugra Ozdoganlar
//
//----------------------------------------------

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

///<summary>
/// An example script to show how the RCC API works.
///</summary>
public class RCC_APIExample : RCC_Core {

    public RCC_CarControllerV4 spawnVehiclePrefab;      // Vehicle prefab we gonna spawn.
    private RCC_CarControllerV4 currentVehiclePrefab;       // Spawned vehicle.
    public Transform spawnTransform;        // Spawn transform.

    public bool playerVehicle;      // Spawn as a player vehicle?
    public bool controllable;       // Spawn as controllable vehicle?
    public bool engineRunning;      // Spawn with running engine?

    /// <summary>
    /// Spawning the vehicle with given settings.
    /// </summary>
    public void Spawn() {

        // Spawning the vehicle with given settings.
        currentVehiclePrefab = RCC.SpawnRCC(spawnVehiclePrefab, spawnTransform.position, spawnTransform.rotation, playerVehicle, controllable, engineRunning);

    }

    /// <summary>
    /// Sets the player vehicle.
    /// </summary>
    public void SetPlayer() {

        // Registers the vehicle as player vehicle.
        RCC.RegisterPlayerVehicle(currentVehiclePrefab);

    }

    /// <summary>
    /// Sets controllable state of the player vehicle.
    /// </summary>
    /// <param name="control"></param>
    public void SetControl(bool control) {

        // Enables / disables controllable state of the vehicle.
        RCC.SetControl(currentVehiclePrefab, control);

    }

    /// <summary>
    /// Sets the engine state of the player vehicle.
    /// </summary>
    /// <param name="engine"></param>
    public void SetEngine(bool engine) {

        // Starts / kills engine of the vehicle.
        RCC.SetEngine(currentVehiclePrefab, engine);

    }

    /// <summary>
    /// Deregisters the player vehicle.
    /// </summary>
    public void DeRegisterPlayer() {

        // Deregisters the vehicle from as player vehicle.
        RCC.DeRegisterPlayerVehicle();

    }

}
