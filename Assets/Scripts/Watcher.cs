using UnityEngine;

public class Watcher : MonoBehaviour
{

    private Transform trans;
    private Vector3 offset;
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        trans = GameObject.FindWithTag("MainCamera").GetComponent<Transform>();
        offset = trans.rotation.eulerAngles - transform.rotation.eulerAngles;
    }

    // Update is called once per frame
    void Update()
    {
        Quaternion rot = Quaternion.Euler(trans.rotation.eulerAngles - offset * -1f);
        gameObject.transform.rotation = rot;
    }
}
