using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class CameraRenderDepth : MonoBehaviour
{
    // Start is called before the first frame update
    void Awake()
    {
        GetComponent<Camera>().depthTextureMode = DepthTextureMode.Depth;   
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
