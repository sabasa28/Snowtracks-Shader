using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DrawWithMouse : MonoBehaviour
{
    [SerializeField] Camera _camera;
    [SerializeField] Shader drawShader;
    [SerializeField] Texture2D footprintTexUp;
    [SerializeField] Texture2D footprintTexDown;

    enum dir
    {
        up,
        left,
        right,
        down
    }
    bool rightFoot;
    dir stepingDirection;
    Vector2 lastStep = new Vector2(0 , 0);
    Vector2 movementVec = new Vector2(0, 0);

    private RenderTexture splatmap;
    private Material trackableMaterial;
    private Material drawMaterial;
    RaycastHit hit;
    Vector3 mouseLastPos = new Vector2(0,0);
    void Start()
    {
        drawMaterial = new Material(drawShader);
        drawMaterial.SetVector("_Color", Color.red);

        trackableMaterial = GetComponent<MeshRenderer>().material;
        splatmap = new RenderTexture(1024, 1024, 8, RenderTextureFormat.ARGBFloat);
        trackableMaterial.SetTexture("_Splat", splatmap);
        drawMaterial.SetTexture("_FootTexU", footprintTexUp);
        drawMaterial.SetTexture("_FootTexD", footprintTexDown);
        drawMaterial.SetInt("_DividedIn", 10);
    }

    void Update()
    {

        if (Input.GetKeyDown(KeyCode.Mouse0) && Physics.Raycast(_camera.ScreenPointToRay(Input.mousePosition), out hit, 100.0f, (1 << LayerMask.NameToLayer("Trackable"))))
        {
            movementVec = new Vector2(hit.textureCoord.x, hit.textureCoord.y) - lastStep;
            lastStep = new Vector2(hit.textureCoord.x, hit.textureCoord.y);
            Debug.Log(movementVec.normalized);
            //Debug.Log(new Vector2(hit.textureCoord.x, hit.textureCoord.y));
            drawMaterial.SetVector("_Coordinate", new Vector4(hit.textureCoord.x, hit.textureCoord.y, 0, 0));
            drawMaterial.SetInt("_FlipFoot", rightFoot ? 1 : 0);
            float angleOfStep = Vector2.Angle(Vector2.up, movementVec.normalized);
            if (movementVec.x < 0) angleOfStep = -angleOfStep;
            Debug.Log(angleOfStep);
            drawMaterial.SetFloat("_StepRot", angleOfStep);
            rightFoot = !rightFoot;
            RenderTexture temp = RenderTexture.GetTemporary(splatmap.width, splatmap.height, 0, RenderTextureFormat.ARGBFloat);
            Graphics.Blit(splatmap, temp);
            Graphics.Blit(temp, splatmap, drawMaterial);
            RenderTexture.ReleaseTemporary(temp);
        }
        if (Physics.Raycast(_camera.ScreenPointToRay(Input.mousePosition), out hit, 100.0f, (1 << LayerMask.NameToLayer("Trackable"))))
        { 
            //mouseLastPos = last hit.textureCoord
        }
    }

    void SetStepingDirection(Vector2 direction)
    {
        if (Mathf.Abs(direction.x) > Mathf.Abs(direction.y))
        {
            if (direction.x > 0)
            {
                stepingDirection = dir.right;
            }
            else
            {
                stepingDirection = dir.left;
            }
        }
        else if (Mathf.Abs(direction.x) < Mathf.Abs(direction.y))
        {
            if (direction.y > 0)
            {
                stepingDirection = dir.up;
            }
            else
            {
                stepingDirection = dir.down;
            }
        }
    }

    private void OnGUI()
    {
        GUI.DrawTexture(new Rect(0, 0, 256/2, 256/2), splatmap, ScaleMode.ScaleToFit, false, 1);
        
    }
}
