using UnityEngine;

public class ParticleSystemTrigger : MonoBehaviour
{
    public Material targetMaterial;
    public string floatProperty = ("_MyFloat");

    [Range(-1f, 1f)]
    public float value = 1f;

    [Header("Particle Settings")]
    public ParticleSystem particleSystem;



    // Update is called once per frame
    void Update()
    {
        targetMaterial.SetFloat(floatProperty, value);

        if (value >= 1 || value <= -1)
        {
            particleSystem.Stop();
        }
        else
        {
            particleSystem.Play();
        }
    }
}