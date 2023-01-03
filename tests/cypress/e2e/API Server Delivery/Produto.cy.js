describe('Rotas Produto', () => {
    let id01;
    let id02;

    it('Create Produto 01', () => {
        cy.request({
            method: 'POST',
            url: '/produtos',
            body: {
                "id": 0,
                "nome": "x-tudo",
                "custo": 10.00,
                "percentual_lucro": 50.00,
                "estoque": 50,
            }
        }).then((Response) => {
            expect(Response.status).to.equal(201);
            expect(Response.body[0].message).to.equal('Produto adicionado com sucesso!');
            expect(Response.body[1].nome).to.equal('x-tudo');
            id01 = Response.body[1].id;
        });
    });

    it('Create Produto 02', () => {
        cy.request({
            method: 'POST',
            url: '/produtos',
            body: {
                "id": 0,
                "nome": "pizza calabreza",
                "custo": 25.00,
                "percentual_lucro": 25.00,
                "estoque": 30,
            }
        }).then((Response) => {
            expect(Response.status).to.equal(201);
            expect(Response.body[0].message).to.equal('Produto adicionado com sucesso!');
            expect(Response.body[1].nome).to.equal('pizza calabreza');
            id02 = Response.body[1].id;
        });
    });

    it('Get all Produto', () => {
        cy.request('/produtos').then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body[0].id).to.equal(id01);
            expect(Response.body[0].nome).to.equal('x-tudo');
            expect(Response.body[1].id).to.equal(id02);
            expect(Response.body[1].nome).to.equal('pizza calabreza');
        });
    });

    it('Get Produto 01', () => {
        cy.request(`/produtos/${id01}`).then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body.id).to.equal(id01);
            expect(Response.body.nome).to.equal('x-tudo');
            expect(Response.body.lucro).to.equal(15);
        });
    });

    it('Get Produto 02', () => {
        cy.request(`/produtos/${id02}`).then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body.id).to.equal(id02);
            expect(Response.body.nome).to.equal('pizza calabreza');
            expect(Response.body.lucro).to.equal(31.25);
        });
    });

    it('Update Produto 01', () => {
        cy.request({
            method: 'PUT',
            url: `/produtos/${id01}`,
            body: {
                "id": id01,
                "nome": "x-tudo com calabreza",
                "custo": 10.00,
                "percentual_lucro": 60.00,
                "estoque": 20,
            }
        }).then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body[0].message).to.equal('Produto atualizado com sucesso!');
            expect(Response.body[1].nome).to.equal('x-tudo com calabreza');
            expect(Response.body[1].lucro).to.equal(16);
            expect(Response.body[1].id).to.equal(id01);
        });
    });

    it('Update Produto 02', () => {
        cy.request({
            method: 'PUT',
            url: `/produtos/${id02}`,
            body: {
                "id": id02,
                "nome": "pizza calabreza com bacon",
                "custo": 25.00,
                "percentual_lucro": 75.00,
                "estoque": 20,
            }
        }).then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body[0].message).to.equal('Produto atualizado com sucesso!');
            expect(Response.body[1].nome).to.equal('pizza calabreza com bacon');
            expect(Response.body[1].lucro).to.equal(43.75);
            expect(Response.body[1].id).to.equal(id02);
        });
    });

    it('Delete Produto 01', () => {
        cy.request({
            method: 'DELETE',
            url: `/produtos/${id01}`
        }).then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body.message).to.equal('Produto excluído com sucesso!');
        });
    });

    it('Delete Produto 02', () => {
        cy.request({
            method: 'DELETE',
            url: `/produtos/${id02}`
        }).then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body.message).to.equal('Produto excluído com sucesso!');
        });
    });
});