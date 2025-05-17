using System;
using UnityEngine;
using UnityEngine.AI;
using UnityEngine.Events;

public class InAreaControl : MonoBehaviour
{
    [SerializeField] bool destroyOnAwake;
    [SerializeField] string tagFilter;
    [SerializeField] UnityEvent onTriggerEnter;
    public RCC_CarControllerV4 car;

    public bool isDone = false;
    private Collider OO;
    private bool isIn = false;
    //public AudioSource audioSuccess;
    // Start is called once before the first execution of Update after the MonoBehaviour is created

    void Update()
    {
        if (isIn)
        {
            if (destroyOnAwake && OO.gameObject.CompareTag(tagFilter) && (car.engineRPM <= 1100))
            {
                //Debug.Log("DZINNN " + car.engineRPM);
                isDone = true;
                onTriggerEnter.Invoke();
                destroyOnAwake = false;
            }
        }
    }

    void OnTriggerEnter(Collider other)
    {
        //!String.IsNullOrEmpty(tagFilter) && 
        //if ( other.gameObject.CompareTag(tagFilter))
        OO = other;
        isIn = true;

    }

    void OnTriggerExit(Collider other)
    {
        //Destroy(gameObject);
    }
}
