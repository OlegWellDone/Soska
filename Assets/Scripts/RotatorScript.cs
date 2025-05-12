using UnityEditor.Rendering;
using UnityEngine;
using UnityEngine.Rendering;

public class RotatorScript : MonoBehaviour
{

    public RCC_CarControllerV4 vehicle;
    public bool isRpm;
    public GameObject COM;

private float RPM;
private float KMH;
private Quaternion StartQ;
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        StartQ = this.transform.rotation;
        StartQ.Normalize();
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
            this.transform.rotation = Quaternion.Euler(StartQ.eulerAngles.x - (RPM/1000*30), COM.transform.eulerAngles.y, COM.transform.eulerAngles.z);
            //Debug.Log(""+this.transform.rotation);
        }else {

        }
    }
}
