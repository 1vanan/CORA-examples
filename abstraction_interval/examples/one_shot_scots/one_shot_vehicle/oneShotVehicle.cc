//
// Created by Ivan Fedotov on 10.12.20.
//
#include <iostream>
#include <array>
#include <time.h>

/* SCOTS header */
#include "scots.hh"
/* ode solver */
#include "RungeKutta4.hh"

/* memory profiling */
#include <sys/time.h>
#include <sys/resource.h>

struct rusage usage;

/* state space dim */
const int state_dim = 3;
/* input space dim */
const int input_dim = 2;

/* sampling time */
const double tau = 3;

/*
 * data types for the state space elements and input space
 * elements used in uniform grid and ode solvers
 */
using state_type = std::array<double, state_dim>;
using input_type = std::array<double, input_dim>;
using namespace std;

/* abbrev of the type for abstract states and inputs */
using abs_type = scots::abs_type;

/* we integrate the vehicle ode by tau sec (the result is stored in x)  */
auto vehicle_post = [](state_type &x, const input_type &u) {
    /* the ode describing the vehicle */
    auto rhs = [](state_type &xx, const state_type &x, const input_type &u) {
        double alpha = std::atan(std::tan(u[1]) / 2.0);
        xx[0] = u[0] * std::cos(alpha + x[2]) / std::cos(alpha);
        xx[1] = u[0] * std::sin(alpha + x[2]) / std::cos(alpha);
        xx[2] = u[0] * std::tan(u[1]);
    };
    /* simulate (use 10 intermediate steps in the ode solver) */
    scots::runge_kutta_fixed4(rhs, x, u, state_dim, tau, 10);
};

/* we integrate the growth bound by 0.3 sec (the result is stored in r)  */
auto radius_post = [](state_type &r, const state_type &, const input_type &u) {
    double c = std::abs(u[0]) * std::sqrt(std::tan(u[1]) * std::tan(u[1]) / 4.0 + 1);
    const state_type w = {{0.005, 0.005}};

    r[0] = r[0] + c * r[2] * tau + w[0];
    r[1] = r[1] + c * r[2] * tau + w[1];
};

int main() {
    int dim = 3;
    double rad = 0.005;
    /* to measure time */
    clock_t t;
    state_type x;
    state_type r;
    input_type u;

    for (int i = 0; i < dim; i++) {
        x[i] = 1;
        r[i] = rad;
        u[i] = 1;
    }

    int total = 1;
    bool inside = true;
    double left_bound[3] = {-10, -10, 0};
    double right_bound[3] = {10, 10, 20};

    t = clock();
    for (int j = 0; j < 10; j++) {
        // solution with disturbance
        radius_post(r, x, u);
        // solution without disturbance
        vehicle_post(x, u);
        int totalLocal = 1;
        for (int i = 0; i < state_dim; i++) {
            double left = x[i] - r[i];
            double right = x[i] + r[i];
            if (right < left_bound[i] || left > right_bound[i]) {
                inside = false;
                break;
            }
            std::cout << "iteration: " << j << "  dimension: " << i << "  left: " << left << "  right: " << right
                      << "\n";

            totalLocal *= ceil(right/(rad * 2)) - floor(left/(rad * 2));

            cout << "num: " << totalLocal << "\n";
        }
        if (!inside) {
            break;
        }
        total += totalLocal;
    }
    t = clock() - t;
    std::cout << "total: " << total << "\n";
    printf ("It took me %d clicks (%f seconds).\n",t,((float)t)/CLOCKS_PER_SEC);
    return 0;
}