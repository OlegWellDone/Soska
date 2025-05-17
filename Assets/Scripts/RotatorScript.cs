using UnityEditor.Rendering;
using UnityEngine;
using UnityEngine.Rendering;

public class RotatorScript : MonoBehaviour
{

    public RCC_CarControllerV4 vehicle;

    public GameObject hmNeedle;
    public GameObject kmhNeedle;

private float RPM;
private float KMH;
private Quaternion StartQh;
private Quaternion StartQk;
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        StartQh = hmNeedle.transform.localRotation;
        StartQk = kmhNeedle.transform.localRotation;
        //StartQ.Normalize();
    }

    // Update is called once per frame
    void Update()
    {
        RPM = vehicle.engineRPM;
        KMH = vehicle.speed;
        //Debug.Log(RPM + " oo " + KMH);
        //30 градусов, так как 240 градусов всего поворот максимум/ 8к оборотов.
        
            //this.transform.rotation.eulerAngles.y+StartQ.eulerAngles.y
            //this.transform.localEulerAngles = 
            hmNeedle.transform.localRotation = Quaternion.Euler(StartQh.eulerAngles.x - (RPM/1000*30), StartQh.eulerAngles.y, StartQh.eulerAngles.z);
            //Debug.Log(""+KMH + "  " + StartQk.eulerAngles.x + (KMH));
        
            kmhNeedle.transform.localRotation = Quaternion.Euler(StartQk.eulerAngles.x - (KMH*1.7f), StartQk.eulerAngles.y, StartQk.eulerAngles.z);
        
    }
}
