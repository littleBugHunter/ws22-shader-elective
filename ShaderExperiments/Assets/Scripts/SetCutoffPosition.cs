/* A C# Component
 * <author>Paul Nasdalack</author>
 */
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
[RequireComponent(typeof(Renderer))]
public class SetCutoffPosition : MonoBehaviour
{
#region Serialized Fields
	[SerializeField]
	private Transform _waterLineGizmo;
#endregion

#region Private Variables
	private Renderer _renderer;
#endregion

#region Unity Functions
	private void OnEnable()
	{
		_renderer = GetComponent<Renderer>();
	}

	private void Update()
	{
		if(_waterLineGizmo != null)
		{
			var propertyBlock = new MaterialPropertyBlock();
			propertyBlock.SetVector("_CutoffPosition", _waterLineGizmo.position);
			propertyBlock.SetVector("_CutoffNormal", _waterLineGizmo.up);
			_renderer.SetPropertyBlock(propertyBlock);
		}
	}
#endregion
}
