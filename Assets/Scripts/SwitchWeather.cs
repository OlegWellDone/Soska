using UnityEngine;
using UnityEngine.InputSystem.Controls;

public class SwitchWeather : MonoBehaviour
{

    public GameObject[] Ground;

    public PhysicsMaterial[] GroundType;

    
    //public int typeG;
    

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
        if(Input.GetKey("1")){
            WeatherChange(1);
        } else if(Input.GetKey("2")){
            WeatherChange(2);
            
        }
    }

    void WeatherChange(int typeG){
        switch(typeG){
            case 1:{
                //asphalt
                foreach(GameObject obj in Ground){
                    obj.GetComponent<MeshCollider>().material = GroundType[0];
                }
            }break;
            case 2:{
                //rain
                foreach(GameObject obj in Ground){
                    obj.GetComponent<MeshCollider>().material = GroundType[1];
                }
            }break;
            case 3: {
                //sand
                foreach(GameObject obj in Ground){
                    obj.GetComponent<MeshCollider>().material = GroundType[2];
                }
            }break;
        }
    }
}
