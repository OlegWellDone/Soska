using UnityEngine;

public class Blinkig : MonoBehaviour
{

    public Light lightIndicator;
    public GameObject blinkingLight;
    public Material materiallight;
    public Material materialdark;

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        blinkingLight.GetComponent<MeshRenderer>().material = materialdark;
    }

    // Update is called once per frame
    void Update()
    {
        if(lightIndicator.intensity > 0){
            blinkingLight.GetComponent<MeshRenderer>().material = materiallight;
        } else {
            blinkingLight.GetComponent<MeshRenderer>().material = materialdark;
        }
    }
}
