using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class Player : MonoBehaviour
{
    [SerializeField] private Animator animator;
    [SerializeField] private NavMeshAgent agent;
    [SerializeField] private float walkSpeed = 2f;
    [SerializeField] private float runSpeed = 5f;
    [SerializeField] private List<Transform> points = new List<Transform>();
    private int currentPointIndex = 0;
    private Vector3 targetPosition;
    private bool isRunning = true;

    private void Start()
    {
        SetNextPoint();
        agent.SetDestination(targetPosition);
    }

    private void Update()
    {
        if (Vector3.Distance(targetPosition, transform.position) <= agent.stoppingDistance)
        {
            SetNextPoint();
            agent.SetDestination(targetPosition);
        }
    }

    private void SetNextPoint()
    {
        isRunning = !isRunning;
        if(isRunning)
        {
            agent.speed = runSpeed;
            animator.SetFloat("Run", 1f);
        }
        else
        {
            agent.speed = walkSpeed;
            animator.SetFloat("Run", 0);
        }
        currentPointIndex = currentPointIndex + 1 < points.Count ? currentPointIndex + 1 : 0;
        targetPosition = points[currentPointIndex].position;
    }
}
