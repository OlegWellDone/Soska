﻿//----------------------------------------------
//            BCG Shared Assets
//
// Copyright © 2014 - 2021 BoneCracker Games
// https://www.bonecrackergames.com
// Ekrem Bugra Ozdoganlar
//
//----------------------------------------------

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;

/// <summary>
/// Receiving inputs from UI Joystick.
/// </summary>
public class BCG_Joystick : MonoBehaviour, IDragHandler, IPointerUpHandler, IPointerDownHandler {

    public RectTransform backgroundSprite;
    public RectTransform handleSprite;

    internal Vector2 inputVector = Vector2.zero;
    public float inputHorizontal { get { return inputVector.x; } }
    public float inputVertical { get { return inputVector.y; } }

    private Vector2 joystickPosition = Vector2.zero;
    private Camera _refCam = new Camera();

    void Start() {

        joystickPosition = RectTransformUtility.WorldToScreenPoint(_refCam, backgroundSprite.position);

    }

    public void OnDrag(PointerEventData eventData) {

        Vector2 direction = eventData.position - joystickPosition;
        inputVector = (direction.magnitude > backgroundSprite.sizeDelta.x / 2f) ? direction.normalized : direction / (backgroundSprite.sizeDelta.x / 2f);
        handleSprite.anchoredPosition = (inputVector * backgroundSprite.sizeDelta.x / 2f) * 1f;

    }

    public void OnPointerUp(PointerEventData eventData) {

        inputVector = Vector2.zero;
        handleSprite.anchoredPosition = Vector2.zero;

    }

    public virtual void OnPointerDown(PointerEventData eventData) {



    }

    void OnDisable() {

        inputVector = Vector2.zero;
        handleSprite.anchoredPosition = Vector2.zero;

    }

}
