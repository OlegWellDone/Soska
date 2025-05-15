using UnityEditor.Rendering;
using UnityEngine;
using UnityEngine.Rendering;

public class RotatorScript : MonoBehaviour
{

    public RCC_CarControllerV4 vehicle;
    public bool isRpm;

private float RPM;
private float KMH;
private Quaternion StartQ;
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        StartQ = this.transform.localRotation;
        //StartQ.Normalize();
    }

    // Update is called once per frame
    void Update()
    {
        RPM = vehicle.engineRPM;
        KMH = vehicle.speed;
        //Debug.Log(RPM + " oo " + KMH);
        //30 градусов, так как 240 градусов всего поворот максимум/ 8к оборотов.
        if (isRpm){
            //this.transform.rotation.eulerAngles.y+StartQ.eulerAngles.y
            //this.transform.localEulerAngles = 
            this.transform.localEulerAngles = new Vector3(StartQ.eulerAngles.x - (RPM/1000*30), StartQ.eulerAngles.y, StartQ.eulerAngles.z);
            //Debug.Log(""+this.transform.rotation);
        }else {
             this.transform.localEulerAngles = new Vector3(StartQ.eulerAngles.x + (KMH/160*1.5f), StartQ.eulerAngles.y, StartQ.eulerAngles.z);
        }
    }
}
