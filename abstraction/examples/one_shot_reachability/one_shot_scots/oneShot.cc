//
// Created by Ivan Fedotov on 10.12.20.
//
#include <iostream>
#include <array>

/* SCOTS header */
#include "scots.hh"
/* ode solver */
#include "RungeKutta4.hh"

/* time profiling */
#include "TicToc.hh"
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
    const state_type w = {{0.05, 0.05}};

    r[0] = r[0] + c * r[2] * tau + w[0];
    r[1] = r[1] + c * r[2] * tau + w[1];
};

int main() {

    int dim = 3;
    double rad = 0.005;
    /* to measure time */
    TicToc tt;
    state_type x;
    state_type r;
    input_type u;

    for (int i = 0; i < dim; i++){
        x[i] = 1;
        r[i] = rad;
        u[i] = 1;
    }
    // solution with disturbance
    radius_post(r, x, u);
    // solution without disturbance
    vehicle_post(x, u);

    int total = 1;

    for(int i = 0; i < dim; i++){
        double left = x[i] - r[i];
        double right = x[i] + r[i];

        std::cout << "dimension: " << i << "\n";
        std::cout << "left: " << left << "\n";
        std::cout << "right: " << right << "\n";
        std::cout << "amount of steps: " << (right - left)/(rad*2) << "\n";

        total *= std::round((right - left)/(rad*2));
    }

    std::cout << "total: " << total << "\n";

    return 0;
}