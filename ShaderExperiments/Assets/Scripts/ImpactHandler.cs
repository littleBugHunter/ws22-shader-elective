using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(MeshRenderer))]
public class ImpactHandler : MonoBehaviour
{
    private Material m_material;

    void Start()
    {
        // Get our assigned Material
        MeshRenderer meshRenderer = GetComponent<MeshRenderer>();
        m_material = meshRenderer.material;
    }

    void OnCollisionEnter(Collision collision)
    {
        // Where did we get hit?
        Vector3 hitPos = collision.contacts[0].point;
        m_material.SetVector("_HitPos", hitPos);
        m_material.SetFloat("_HitTime", Time.time);
    }
}
