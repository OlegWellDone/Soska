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
using UnityEngine.Rendering;

/// <summary>
/// General lighting system for vehicles. It has all kind of lights such as Headlight, Brake Light, Indicator Light, Reverse Light, Park Light, etc...
/// </summary>
[RequireComponent(typeof(Light))]
public class RCC_Light : RCC_Core {

    // Actual light component.
    public Light LightSource {
        get {
            if (_light == null)
                _light = GetComponent<Light>();
            return _light;
        }
    }
    private Light _light;

    public LensFlare lensFlare;        //  Lensflare if used.
#if RCC_URP
    public LensFlareComponentSRP lensFlareURP;     //   URP lensflare if used.
#endif
    public TrailRenderer trail;        //  Trailrenderer in used.

    public float defaultIntensity = 1f;     //  Default intensity of the light.
    public float flareBrightness = 1.5f;        //  Max flare brigthness of the light.
    private float finalFlareBrightness;     //  Calculated final flare brightness of the light.

    public LightType lightType = LightType.HeadLight;       //  Light type.
    public enum LightType { HeadLight, BrakeLight, ReverseLight, Indicator, ParkLight, HighBeamHeadLight, External, Interior };
    public float inertia = 1f;      //  Light inertia. 
    public LightRenderMode renderMode = LightRenderMode.Auto;
    public bool overrideRenderMode = false;
    public Flare flare;     //  Lensflare if used.

    public int refreshRate = 30;        //  Refresh rate.
    private float refreshTimer = 0f;        //  Refresh rate interval timer.

    private bool parkLightFound = false;        //  If park light found, this means don't illuminate brake lights for tail lights.
    private bool highBeamLightFound = false;        //  If high beam light found, this means don't illuminate normal headlights for high beam headlights.

    public RCC_Emission[] emission;     //  Emission for illuminating the texture.
    public bool useEmissionTexture = false;     //  Use the emission texture.

    public float strength = 100f;       //  	Strength of the light. 
    private float orgStrength = 100f;       //	Original strength of the light. We will be using this original value while restoring the light.

    public bool isBreakable = true;     //	Can it break at certain damage?
    public int breakPoint = 35;     //	    Light will be broken at this point.
    private bool broken = false;        //	Is this light broken currently?

    // For Indicators.
    private RCC_CarControllerV4.IndicatorsOn indicatorsOn;
    private AudioSource indicatorSound;
    public AudioClip IndicatorClip { get { return Settings.indicatorClip; } }

    private void Awake() {

        //  Initializing the light is it's attached to the vehicle. Do not init the light if it's not attached to the vehicle (Used for trailers. Trailers have not main car controller script. Assigning car controller of the light when trailer is attached/detached).
        Initialize();

    }

    /// <summary>
    /// Initializes the light.
    /// </summary>
    public void Initialize() {

        //  Getting actual light component, make sure it's enabled. And then getting lensflare and trailrenderer if attached.
        lensFlare = GetComponent<LensFlare>();
#if RCC_URP
        lensFlareURP = GetComponent<LensFlareComponentSRP>();
#endif
        trail = GetComponentInChildren<TrailRenderer>();

        //  Make sure light is enabled.
        LightSource.enabled = true;

        //  If default intensity of the light is set to 0, override it.
        defaultIntensity = LightSource.intensity;

        orgStrength = strength;     //      Getting original strength of the light. We will be using this original value while restoring the light.

        //  If lensflare found, set brightness to 0, color to white, and set flare texture. This is only for initialization process.
        if (lensFlare) {

            lensFlare.brightness = 0f;
            lensFlare.color = Color.white;
            lensFlare.fadeSpeed = 20f;

            if (LightSource.flare != null)
                LightSource.flare = null;

            lensFlare.flare = flare;

        }

        //  If lensflare found, set brightness to 0, color to white, and set flare texture. This is only for initialization process.
#if RCC_URP
        if (lensFlareURP)
            lensFlareURP.intensity = 0f;
#endif

        if (!overrideRenderMode) {

            switch (lightType) {

                case LightType.HeadLight:

                    //  If light option in RCC Settings is set to "Use Vertex", set render mode of the light to "ForceVertex". Otherwise, force to "ForcePixel".
                    if (Settings.useHeadLightsAsVertexLights)
                        renderMode = LightRenderMode.ForceVertex;
                    else
                        renderMode = LightRenderMode.ForcePixel;

                    break;

                case LightType.BrakeLight:

                    //  If light option in RCC Settings is set to "Use Vertex", set render mode of the light to "ForceVertex". Otherwise, force to "ForcePixel".
                    if (Settings.useBrakeLightsAsVertexLights)
                        renderMode = LightRenderMode.ForceVertex;
                    else
                        renderMode = LightRenderMode.ForcePixel;

                    break;

                case LightType.ReverseLight:

                    //  If light option in RCC Settings is set to "Use Vertex", set render mode of the light to "ForceVertex". Otherwise, force to "ForcePixel".
                    if (Settings.useReverseLightsAsVertexLights)
                        renderMode = LightRenderMode.ForceVertex;
                    else
                        renderMode = LightRenderMode.ForcePixel;

                    break;

                case LightType.Indicator:

                    //  If light option in RCC Settings is set to "Use Vertex", set render mode of the light to "ForceVertex". Otherwise, force to "ForcePixel".
                    if (Settings.useIndicatorLightsAsVertexLights)
                        renderMode = LightRenderMode.ForceVertex;
                    else
                        renderMode = LightRenderMode.ForcePixel;

                    break;

                case LightType.ParkLight:

                    //  If light option in RCC Settings is set to "Use Vertex", set render mode of the light to "ForceVertex". Otherwise, force to "ForcePixel".
                    if (Settings.useOtherLightsAsVertexLights)
                        renderMode = LightRenderMode.ForceVertex;
                    else
                        renderMode = LightRenderMode.ForcePixel;

                    break;

                case LightType.External:

                    //  If light option in RCC Settings is set to "Use Vertex", set render mode of the light to "ForceVertex". Otherwise, force to "ForcePixel".
                    if (Settings.useOtherLightsAsVertexLights)
                        renderMode = LightRenderMode.ForceVertex;
                    else
                        renderMode = LightRenderMode.ForcePixel;

                    break;

            }

        }

        LightSource.renderMode = renderMode;

        if (CarController) {

            //  If light type is indicator, create audiosource for indicator.
            if (lightType == LightType.Indicator) {

                if (!CarController.transform.Find("All Audio Sources/Indicator Sound AudioSource"))
                    indicatorSound = NewAudioSource(Settings.audioMixer, CarController.gameObject, "Indicator Sound AudioSource", 1f, 3f, 1, IndicatorClip, false, false, false);
                else
                    indicatorSound = CarController.transform.Find("All Audio Sources/Indicator Sound AudioSource").GetComponent<AudioSource>();

            }

            //  Getting all lights attached to this vehicle.
            RCC_Light[] allLights = CarController.AllLights;

            //  Checking if vehicle has park light or highbeam headlight. 
            //  If park light found, this means don't illuminate brake lights for tail lights.
            //  If high beam light found, this means don't illuminate normal headlights for high beam headlights.
            for (int i = 0; i < allLights.Length; i++) {

                if (allLights[i].lightType == LightType.ParkLight)
                    parkLightFound = true;

                if (allLights[i].lightType == LightType.HighBeamHeadLight)
                    highBeamLightFound = true;

            }

        }

    }

    private void OnEnable() {

        //  Make sure intensity of the light is set to 0 on enable.
        LightSource.intensity = 0f;

    }

    private void Update() {

        //  If no car controller found, return.
        if (!CarController)
            return;

#if RCC_URP
        //  If lensflare found, use them.
        if (lensFlare || lensFlareURP)
            LensFlare();
#else
        //  If lensflare found, use them.
        if (lensFlare)
            LensFlare();
#endif

        //  If trail renderer found, use them.
        if (trail)
            TrailRenderer();

        //  If use emission texture is enabled, use them.
        if (useEmissionTexture) {

            foreach (RCC_Emission item in emission)
                item.Emission(LightSource);

        }

        //  If light is broken due to damage, set intensity of the light to 0.
        if (broken) {

            Lighting(0f);
            return;

        }

        //  Light types. Illuminating lights with given values.
        switch (lightType) {

            case LightType.HeadLight:
                if (highBeamLightFound) {

                    Lighting(CarController.lowBeamHeadLightsOn ? defaultIntensity : 0f, 50f, 90f);

                } else {

                    Lighting(CarController.lowBeamHeadLightsOn ? defaultIntensity : 0f, 50f, 90f);

                    if (!CarController.lowBeamHeadLightsOn && !CarController.highBeamHeadLightsOn)
                        Lighting(0f);
                    if (CarController.lowBeamHeadLightsOn && !CarController.highBeamHeadLightsOn) {
                        Lighting(defaultIntensity, 50f, 90f);
                        transform.localEulerAngles = new Vector3(10f, 0f, 0f);
                    } else if (CarController.highBeamHeadLightsOn) {
                        Lighting(defaultIntensity, 100f, 45f);
                        transform.localEulerAngles = new Vector3(0f, 0f, 0f);
                    }

                }
                break;

            case LightType.BrakeLight:

                if (parkLightFound)
                    Lighting(CarController.brakeInput >= .1f ? defaultIntensity : 0f);
                else
                    Lighting(CarController.brakeInput >= .1f ? defaultIntensity : !CarController.lowBeamHeadLightsOn ? 0f : .25f);
                break;

            case LightType.ReverseLight:
                Lighting(CarController.direction == -1 ? defaultIntensity : 0f);
                break;

            case LightType.ParkLight:
                Lighting((!CarController.lowBeamHeadLightsOn ? 0f : defaultIntensity));
                break;

            case LightType.Indicator:
                indicatorsOn = CarController.indicatorsOn;
                Indicators();
                break;

            case LightType.HighBeamHeadLight:
                Lighting(CarController.highBeamHeadLightsOn ? defaultIntensity : 0f, 200f, 45f);
                break;

            case LightType.Interior:
                Lighting(CarController.interiorLightsOn ? defaultIntensity : 0f);
                break;

        }

    }

    /// <summary>
    /// Illuminates the light with given input (intensity).
    /// </summary>
    /// <param name="input"></param>
    private void Lighting(float input) {

        if (input >= .05f)
            LightSource.intensity = Mathf.Lerp(LightSource.intensity, input, Time.deltaTime * inertia * 20f);
        else
            LightSource.intensity = 0f;

    }

    /// <summary>
    /// Illuminates the light with given input (intensity), range, and spot angle..
    /// </summary>
    /// <param name="input"></param>
    /// <param name="range"></param>
    /// <param name="spotAngle"></param>
    private void Lighting(float input, float range, float spotAngle) {

        if (input >= .05f)
            LightSource.intensity = Mathf.Lerp(LightSource.intensity, input, Time.deltaTime * inertia * 20f);
        else
            LightSource.intensity = 0f;

        LightSource.range = range;
        LightSource.spotAngle = spotAngle;

    }

    /// <summary>
    /// Operating indicators with timer.
    /// </summary>
    private void Indicators() {

        //  Is this indicator at left or right side?
        Vector3 relativePos = CarController.transform.InverseTransformPoint(transform.position);

        //  If indicator is at left side, and indicator is set to left side as well, illuminate the light with timer.
        //  If indicator is at right side, and indicator is set to right side as well, illuminate the light with timer.
        //  Play created audio source while illuminating the light.
        switch (indicatorsOn) {

            case RCC_CarControllerV4.IndicatorsOn.Left:

                if (relativePos.x > 0f) {

                    Lighting(0);
                    break;

                }

                if (CarController.indicatorTimer >= .5f) {

                    Lighting(0);

                    if (indicatorSound && indicatorSound.isPlaying)
                        indicatorSound.Stop();

                } else {

                    Lighting(defaultIntensity);

                    if (indicatorSound && !indicatorSound.isPlaying && CarController.indicatorTimer <= .05f)
                        indicatorSound.Play();

                }

                if (CarController.indicatorTimer >= 1f)
                    CarController.indicatorTimer = 0f;

                break;

            case RCC_CarControllerV4.IndicatorsOn.Right:

                if (relativePos.x < 0f) {

                    Lighting(0);
                    break;

                }

                if (CarController.indicatorTimer >= .5f) {

                    Lighting(0);

                    if (indicatorSound && indicatorSound.isPlaying)
                        indicatorSound.Stop();

                } else {

                    Lighting(defaultIntensity);

                    if (indicatorSound && !indicatorSound.isPlaying && CarController.indicatorTimer <= .05f)
                        indicatorSound.Play();

                }

                if (CarController.indicatorTimer >= 1f)
                    CarController.indicatorTimer = 0f;

                break;

            case RCC_CarControllerV4.IndicatorsOn.All:

                if (CarController.indicatorTimer >= .5f) {

                    Lighting(0);

                    if (indicatorSound && indicatorSound.isPlaying)
                        indicatorSound.Stop();

                } else {

                    Lighting(defaultIntensity);

                    if (indicatorSound && !indicatorSound.isPlaying && CarController.indicatorTimer <= .05f)
                        indicatorSound.Play();

                }

                if (CarController.indicatorTimer >= 1f)
                    CarController.indicatorTimer = 0f;

                break;

            case RCC_CarControllerV4.IndicatorsOn.Off:

                Lighting(0);
                CarController.indicatorTimer = 0f;
                break;

        }

    }

    /// <summary>
    /// Operating lensflares related to camera angle.
    /// </summary>
    private void LensFlare() {

        //  Lensflares are not affected by collider of the vehicle. They will ignore it. Below code will calculate the angle of the light-camera, and sets intensity of the lensflare.

        //  Working with refresh rate.
        if (refreshTimer > (1f / refreshRate)) {

            refreshTimer = 0f;

            if (!Camera.main)
                return;

            float distanceTocam = Vector3.Distance(transform.position, Camera.main.transform.position);
            float angle;

            if (lightType != LightType.External && lightType != LightType.Interior) {

                angle = Vector3.Angle(transform.forward, Camera.main.transform.position - transform.position);
                finalFlareBrightness = flareBrightness * (4f / distanceTocam) * ((300f - (3f * angle)) / 300f) / 3f;

            } else {

                finalFlareBrightness = flareBrightness * (4f / distanceTocam) / 3f;

            }

            if (lensFlare) {

                lensFlare.brightness = finalFlareBrightness * LightSource.intensity;
                lensFlare.color = LightSource.color;

            }

#if RCC_URP
            if (lensFlareURP)
                lensFlareURP.intensity = finalFlareBrightness * LightSource.intensity;
#endif

        }

        refreshTimer += Time.deltaTime;

    }

    /// <summary>
    /// Operating trailrenderers.
    /// </summary>
    private void TrailRenderer() {

        //  If intensity of the light is high enough, enable emission of the trail renderer. And set color.
        trail.emitting = LightSource.intensity > .1f ? true : false;
        trail.startColor = LightSource.color;

    }

    /// <summary>
    /// Checks rotation of the light if it's facing to wrong direction.
    /// </summary>
    private void CheckRotation() {

        Vector3 relativePos = CarController.transform.InverseTransformPoint(transform.position);

        //  If light is at front side...
        if (relativePos.z > 0f) {

            //  ... and Y rotation of the light is over 90 degrees, reset it to 0.
            if (Mathf.Abs(transform.localRotation.y) > .5f)
                transform.localRotation = Quaternion.identity;

        } else {

            //  If light is at rear side...
            //  ... and Y rotation of the light is over 90 degrees, reset it to 0.
            if (Mathf.Abs(transform.localRotation.y) < .5f)
                transform.localRotation = Quaternion.Euler(0f, 180f, 0f);

        }

    }

    /// <summary>
    /// Listening vehicle collisions for braking the light.
    /// </summary>
    /// <param name="impulse"></param>
    public void OnCollision(float impulse) {

        // If light is broken, return.
        if (broken)
            return;

        //	Decreasing strength of the light related to collision impulse.
        strength -= impulse * 20f;
        strength = Mathf.Clamp(strength, 0f, Mathf.Infinity);

        //	Check joint of the part based on strength.
        if (strength <= breakPoint)
            broken = true;

    }

    /// <summary>
    /// Repairs, and restores the light.
    /// </summary>
    public void OnRepair() {

        strength = orgStrength;
        broken = false;

    }

    private void OnDisable() {

        //  Make sure intensity of the light is set to 0 on disable.
        LightSource.intensity = 0f;

    }

    private void Reset() {

        CheckRotation();

    }

    private void OnValidate() {

        if (emission != null) {

            foreach (RCC_Emission item in emission) {

                if (item.multiplier == 0)
                    item.multiplier = 1f;

            }

        }

    }

}
