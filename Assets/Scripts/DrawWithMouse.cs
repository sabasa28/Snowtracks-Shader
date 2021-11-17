using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DrawWithMouse : MonoBehaviour
{
    [SerializeField] Camera _camera;
    [SerializeField] Shader drawShader;

    private RenderTexture splatmap;
    private Material trackableMaterial;
    private Material drawMaterial;
    RaycastHit hit;

    void Start()
    {
        drawMaterial = new Material(drawShader);
        drawMaterial.SetVector("_Color", Color.red);

        trackableMaterial = GetComponent<MeshRenderer>().material;
        splatmap = new RenderTexture(1024, 1024, 8, RenderTextureFormat.ARGBFloat);
        trackableMaterial.SetTexture("_Splat", splatmap);
    }

    void Update()
    {
        if (Input.GetKey(KeyCode.Mouse0))
        {
            if (Physics.Raycast(_camera.ScreenPointToRay(Input.mousePosition), out hit))
            {
                drawMaterial.SetVector("_Coordinate", new Vector4(hit.textureCoord.x, hit.textureCoord.y, 0, 0));
                RenderTexture temp = RenderTexture.GetTemporary(splatmap.width, splatmap.height, 0, RenderTextureFormat.ARGBFloat);
                Graphics.Blit(splatmap, temp);
                Graphics.Blit(temp, splatmap, drawMaterial);
                RenderTexture.ReleaseTemporary(temp);
            }
        }
    }

    private void OnGUI()
    {
        GUI.DrawTexture(new Rect(0, 0, 256, 256), splatmap, ScaleMode.ScaleToFit, false, 1);
        
    }
}
