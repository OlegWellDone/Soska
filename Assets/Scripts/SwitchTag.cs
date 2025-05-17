using UnityEngine;

public class SwitchTag : MonoBehaviour
{
    [SerializeField] string tagFilter;
    // Start is called once before the first execution of Update after the MonoBehaviour is created

    void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.CompareTag(tagFilter))
        {
            gameObject.tag = "Untagged";
        }
    }
}
