using UnityEngine;

public class ConesCheck : MonoBehaviour
{

    public GameObject[] conesArray;
    public GameObject sample;

    [SerializeField] GameObject[] isDoneOthers;

    private float startCones = 0;
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        conesArray = GameObject.FindGameObjectsWithTag(sample.tag);
        startCones = conesArray.Length;
    }

    // Update is called once per frame

    void OnTriggerEnter(Collider other)
    {
        bool temp = true;
        if (other.gameObject.CompareTag("Vehicle"))
        {
            
            foreach (GameObject isD in isDoneOthers)
            {
                if (isD.GetComponent<InAreaControl>().isDone == false)
                {
                    temp = false;
                }
            }
            
            if (temp)
                {
                    GameObject[] newCones = GameObject.FindGameObjectsWithTag(sample.tag);
                    float newCount = newCones.Length;
                    float kef = newCount / startCones * 100;
                    Debug.Log("kef uspeha" + kef);
                }
        }
    }


}
